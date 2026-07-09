# Swift Testing in Command Line Tools (without full Xcode) ships as a separate
# framework; the SwiftPM test runner needs a global -F flag, otherwise
# canImport(Testing) == false and tests silently do not run.
FRAMEWORKS = /Library/Developer/CommandLineTools/Library/Developer/Frameworks

# The macOS 27 beta SDK declares SwiftUI @State & co. as macros implemented in
# SwiftUIMacros, but Command Line Tools ships no libSwiftUIMacros.dylib, so any
# @State fails with "plugin for module 'SwiftUIMacros' not found". Pin the
# stable 26.5 SDK; fall back to the default SDK once the pinned one is gone.
export SDKROOT ?= $(shell xcrun --sdk macosx26.5 --show-sdk-path 2>/dev/null || xcrun --show-sdk-path)
# Swift Testing macros (#expect, @Test) live in a plugin the explicit-modules
# build does not find on its own; both flags are harmless with full Xcode.
TESTING_PLUGINS = /Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing
TESTFLAGS = -Xswiftc -F -Xswiftc $(FRAMEWORKS) \
            -Xswiftc -plugin-path -Xswiftc $(TESTING_PLUGINS)

APP_NAME = Mole Widget
DIST = dist/$(APP_NAME).app

.PHONY: run test app install clean

run:
	swift run MoleWidget

# make test            — run all tests
# make test FILTER=Fmt — run only suites/tests matching FILTER
test:
	swift test $(TESTFLAGS) $(if $(FILTER),--filter $(FILTER))

app:
	swift build -c release
	rm -rf "$(DIST)"
	mkdir -p "$(DIST)/Contents/MacOS"
	cp .build/release/MoleWidget "$(DIST)/Contents/MacOS/MoleWidget"
	cp Resources/Info.plist "$(DIST)/Contents/Info.plist"
	mkdir -p "$(DIST)/Contents/Resources"
	cp Resources/AppIcon.icns "$(DIST)/Contents/Resources/AppIcon.icns"
	mkdir -p "$(DIST)/Contents/Frameworks"
	cp -R .build/release/Sparkle.framework "$(DIST)/Contents/Frameworks/Sparkle.framework"
	install_name_tool -add_rpath "@executable_path/../Frameworks" "$(DIST)/Contents/MacOS/MoleWidget"
	mkdir -p "$(DIST)/Contents/PlugIns/MoleWidgetExtension.appex/Contents/MacOS"
	cp .build/release/MoleWidgetExtension "$(DIST)/Contents/PlugIns/MoleWidgetExtension.appex/Contents/MacOS/MoleWidgetExtension"
	cp Resources/WidgetExtension-Info.plist "$(DIST)/Contents/PlugIns/MoleWidgetExtension.appex/Contents/Info.plist"
	codesign --force --sign - "$(DIST)/Contents/PlugIns/MoleWidgetExtension.appex"
	codesign --force --sign - "$(DIST)/Contents/Frameworks/Sparkle.framework"
	codesign --force --sign - "$(DIST)"
	@echo "Done: $(DIST)"

# Widget gallery registration is most reliable from /Applications.
install: app
	pkill -x MoleWidget || true
	rm -rf "/Applications/$(APP_NAME).app"
	ditto "$(DIST)" "/Applications/$(APP_NAME).app"
	open "/Applications/$(APP_NAME).app"

clean:
	rm -rf .build dist
