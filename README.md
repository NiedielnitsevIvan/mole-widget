# Mole Widget

[![CI](https://github.com/NiedielnitsevIvan/mole-widget/actions/workflows/ci.yml/badge.svg)](https://github.com/NiedielnitsevIvan/mole-widget/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Fork of [TadelUnso/mole-widget](https://github.com/TadelUnso/mole-widget) with a system-native restyle and a WidgetKit widget on top.

**Mole Widget** is a lightweight macOS desktop system monitor widget: live CPU, memory, disk, network, battery and process metrics right on your desktop. Native Swift + SwiftUI — a borderless window living at desktop level, above the wallpaper and below application windows.

<img src="assets/widget.webp" width="520" alt="Mole Widget on the desktop">

## What this fork adds

- **System-native look** — adaptive light/dark system-semantic colors instead of the fixed Catppuccin terminal palette, hierarchical system styles for the title-bar controls
- **Liquid Glass** — on macOS 26+ the panel is a Liquid Glass surface, with the background-opacity setting acting as the glass tint
- **Narrow layout** — the window resizes down to 330 pt (upstream: 490) and folds to a single column below 460 pt
- **Inline bar labels** — values are drawn inside the capacity bars for tighter rows
- **Widget-gallery widget** — a "Mole System Status" WidgetKit widget (small and medium) for the macOS widget gallery: CPU, memory and disk at a glance; the medium size carries the full desktop S preset — cores, load average, temperature, memory detail and a usage-history sparkline. The running app nudges its timelines every minute; standalone it refreshes about every 5 minutes
- `make install` — build and install straight into /Applications

## Features

- **Header** — chip, RAM, macOS version, uptime and a composite health score (0–100)
- **CPU** — total usage, top-3 busiest cores, load average, SoC temperature, usage trend sparkline
- **Memory** — used/free, total, cached, available
- **Disk** — root volume usage, used/free space, read/write speed
- **Power** — charge level, battery health, status, cycle count, temperature
- **Network** — download/upload sparklines with rates, active interface and local IP
- **Processes** — top-3 by CPU with memory footprint
- Click any section title to open Activity Monitor
- Visible on all Spaces, ignored by Mission Control and ⌘Tab, stays below regular windows
- Drag it anywhere with the mouse; position is remembered across launches
- Resizable: drag the right edge to adjust the width (330–880 pt), saved across launches; below 460 pt the layout folds to a single column
- 🔒 Clickable lock icon on the widget (plus a "Lock position" menu item) pins both position and size
- Hide the widget with the eye icon on it; bring it back via **Show on desktop** in the menu bar. The hidden state is remembered across launches
- **Usage History** — up to 12 hours of CPU and RAM history with a 1h/4h/12h range switch and a scrubber; pick any moment to see which processes were heaviest then. Open it from the menu bar
- **Menu bar metrics** — show live CPU, memory, and CPU temperature in the menu bar (each toggleable). Values turn yellow past 60% and red past 85%, and stay live even while the widget is hidden
- Settings in the menu bar: background opacity (glass tint on macOS 26+), visible sections, refresh rate (1/2/5 s), font size and style (monospaced or system)
- Launch at login toggle; no Dock icon

## Requirements

- macOS 14+ to run (Liquid Glass and the system restyle kick in on macOS 26+)
- To build: Swift 6 toolchain with the macOS 26 SDK — Command Line Tools are enough (`xcode-select --install`), full Xcode is not required. The Makefile pins the 26.5 SDK to work around a CLT 27 beta issue

## Install

### From source

```bash
make install   # builds dist/Mole Widget.app and installs it into /Applications
```

Or just build without installing:

```bash
make app
open "dist/Mole Widget.app"
```

### Prebuilt (upstream)

The signed, notarized DMG on the upstream [Releases page](https://github.com/TadelUnso/mole-widget/releases) and the `TadelUnso/tap/mole-widget` Homebrew cask install the **original** app — they do not include this fork's additions.

## Uninstall

1. Toggle off **Launch at login** in the menu bar (if you enabled it) and quit the widget
2. Delete **Mole Widget.app** from /Applications
3. Optional cleanup — remove the saved settings:

```bash
defaults delete com.sbezbabnykh.mole-widget
```

> Uninstalled while the widget was still running? The orphaned process keeps
> the widget on screen — quit it with:
>
> ```bash
> pkill -f "Mole Widget"
> ```

## Feedback

Found a bug or have an idea? [Open an issue](https://github.com/NiedielnitsevIvan/mole-widget/issues) —
bug reports and feature requests are both welcome. For issues that also affect the
original app, use the [upstream tracker](https://github.com/TadelUnso/mole-widget/issues).

## Development

```bash
make run    # run a dev build
make test   # run the test suite (128 tests)
```

> **Important:** run tests only via `make test`. On a machine without full Xcode
> a bare `swift test` silently runs zero tests and exits 0 — the Makefile passes
> the toolchain flags required for Swift Testing from Command Line Tools.

## Architecture

```
Sources/MoleWidgetCore/      — library
  CPU|Memory|Disk|Power/     — one module per domain: pure math + collector
  Store/MetricsStore.swift   — @Observable store, 2/30/60 s timers
  Views/                     — SwiftUI, system-semantic theme
Sources/MoleWidget/          — app shell: desktop-level window, MenuBarExtra
Sources/MoleWidgetExtension/ — WidgetKit appex: "Mole System Status" widget
```

All computation is pure functions over raw snapshots (unit-tested); collectors are thin wrappers around mach APIs / IOKit with smoke tests.
