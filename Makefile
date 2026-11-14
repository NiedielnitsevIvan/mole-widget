# Swift Testing in Command Line Tools (without full Xcode) ships as a separate
# framework; the SwiftPM test runner needs a global -F flag, otherwise
# canImport(Testing) == false and tests silently do not run.
FRAMEWORKS = /Library/Developer/CommandLineTools/Library/Developer/Frameworks

# The macOS 27 beta SDK declares SwiftUI @State & co. as macros implemented in
# SwiftUIMacros, but Command Line Tools ships no libSwiftUIMacros.dylib, so any
# @State fails with "plugin for module 'SwiftUIMacros' not found". Pin the
# stable 26.5 SDK; fall back to the default SDK once the pinned one is gone.
export SDKROOT := $(or $(SDKROOT),$(shell xcrun --sdk macosx26.5 --show-sdk-path 2>/dev/null || xcrun --show-sdk-path))
# Swift Testing macros (#expect, @Test) live in a plugin the explicit-modules
# build does not find on its own; both flags are harmless with full Xcode.
TESTING_PLUGINS = /Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing
TESTFLAGS = -Xswiftc -F -Xswiftc $(FRAMEWORKS) \
            -Xswiftc -plugin-path -Xswiftc $(TESTING_PLUGINS)

APP_NAME = Mole Widget
DIST = dist/$(APP_NAME).app
APPEX = $(DIST)/Contents/PlugIns/MoleWidgetExtension.appex
SPARKLE = $(DIST)/Contents/Frameworks/Sparkle.framework

# Ad-hoc signing by default; the release job passes its Developer ID identity
# (SIGN=...), which also turns on the hardened runtime notarization requires.
SIGN ?= -
CODESIGN = codesign --force --sign "$(SIGN)" $(if $(filter -,$(SIGN)),,--options runtime)
BUILDFLAGS ?=

# WidgetKit exports preferredBackgroundStyle(_:), the glass background of
# Apple's own widgets, without declaring it in the SDK interface. The widget
# extension imports a copy of the SDK interface with the declaration appended
# (Package.swift adds this directory to its module search path).
SPI = .build/spi/WidgetKit.swiftmodule
SDK_WIDGETKIT = $(SDKROOT)/System/Library/Frameworks/WidgetKit.framework/Modules/WidgetKit.swiftmodule

.PHONY: run test app install clean spi

run:
	swift run MoleWidget

spi: $(SPI)

$(SPI): Resources/WidgetKit-SPI.swiftinterface $(SDK_WIDGETKIT)/arm64e-apple-macos.swiftinterface
	rm -rf "$@" && mkdir -p "$(dir $@)"
	cp -R "$(SDK_WIDGETKIT)" "$@"
	# Skip if the SDK ever declares it itself: a second declaration won't compile.
	for f in "$@"/*.swiftinterface; do grep -q preferredBackgroundStyle "$$f" || cat $< >> "$$f"; done

# make test            — run all tests
# make test FILTER=Fmt — run only suites/tests matching FILTER
test: spi
	swift test $(TESTFLAGS) $(if $(FILTER),--filter $(FILTER))

app: spi
	swift build -c release $(BUILDFLAGS)
	rm -rf "$(DIST)"
	mkdir -p "$(DIST)/Contents/MacOS"
	cp .build/release/MoleWidget "$(DIST)/Contents/MacOS/MoleWidget"
	cp Resources/Info.plist "$(DIST)/Contents/Info.plist"
	mkdir -p "$(DIST)/Contents/Resources"
	cp Resources/AppIcon.icns "$(DIST)/Contents/Resources/AppIcon.icns"
	mkdir -p "$(DIST)/Contents/Frameworks"
	cp -R .build/release/Sparkle.framework "$(DIST)/Contents/Frameworks/Sparkle.framework"
	install_name_tool -add_rpath "@executable_path/../Frameworks" "$(DIST)/Contents/MacOS/MoleWidget"
	mkdir -p "$(APPEX)/Contents/MacOS"
	cp .build/release/MoleWidgetExtension "$(APPEX)/Contents/MacOS/MoleWidgetExtension"
	cp Resources/WidgetExtension-Info.plist "$(APPEX)/Contents/Info.plist"
	# The extension takes the app's versions and minimum macOS. chronod caches
	# the widget configuration (families, background style) per extension
	# version, so a release bump refreshes it (`install` also adds a suffix).
	/usr/libexec/PlistBuddy \
		-c "Add :CFBundleShortVersionString string $$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)" \
		-c "Add :CFBundleVersion string $$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' Resources/Info.plist)$(APPEX_BUILD_SUFFIX)" \
		-c "Add :LSMinimumSystemVersion string $$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' Resources/Info.plist)" \
		"$(APPEX)/Contents/Info.plist"
	mkdir -p "$(APPEX)/Contents/Resources"
	cp -R Resources/Fonts "$(APPEX)/Contents/Resources/Fonts"
	# Sign inside-out: the appex, Sparkle's helpers (keeping the XPC services'
	# own entitlements), the framework, then the app.
	$(CODESIGN) --entitlements Resources/WidgetExtension.entitlements "$(APPEX)"
	$(CODESIGN) --preserve-metadata=entitlements,identifier "$(SPARKLE)/Versions/B/XPCServices/Downloader.xpc"
	$(CODESIGN) --preserve-metadata=entitlements,identifier "$(SPARKLE)/Versions/B/XPCServices/Installer.xpc"
	$(CODESIGN) "$(SPARKLE)/Versions/B/Autoupdate"
	$(CODESIGN) "$(SPARKLE)/Versions/B/Updater.app"
	$(CODESIGN) "$(SPARKLE)"
	$(CODESIGN) "$(DIST)"
	@echo "Done: $(DIST)"

# Widget gallery registration is most reliable from /Applications.
# Sync the bundle in place: deleting it makes LaunchServices report the widget
# extension as removed, and Notification Center then drops placed widgets.
# pluginkit -a makes chronod pick up the new appex right away, but a running
# extension process keeps the old code until it exits, so stop it too.
# A fresh extension build number per install makes chronod drop its cached
# widget configuration even when the app version is unchanged.
install: APPEX_BUILD_SUFFIX = .$(shell date +%s)
install: app
	pkill -x MoleWidget || true
	rsync -a --delete "$(DIST)/" "/Applications/$(APP_NAME).app/"
	pluginkit -a "/Applications/$(APP_NAME).app/Contents/PlugIns/MoleWidgetExtension.appex"
	pkill -x MoleWidgetExtension || true
	open "/Applications/$(APP_NAME).app"

clean:
	rm -rf .build dist
