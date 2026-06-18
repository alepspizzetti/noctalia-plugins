# Noctalia Plugin Development Guide

This repository is a custom Noctalia plugin registry. This guide consolidates the parts of the official Noctalia plugin documentation that matter for daily plugin development here, plus the runtime details verified against the local `noctalia-shell` source tree.

Use this document for design and implementation work. Use `docs/noctalia-plugin-publishing-checklist.md` when you are preparing a plugin for publication in this repository.

## Sources

This guide is based on:

- official Noctalia v4 plugin documentation
- the local `noctalia-shell` source tree in `/home/alessandro/Pessoal/noctalia-shell`

When the official docs and the shell implementation differ, treat the shell implementation as the runtime truth and update this guide.

## Official References

- General plugin overview: `https://docs.noctalia.dev/v4/development/plugins/overview/`
- Getting started: `https://docs.noctalia.dev/v4/development/plugins/getting-started/`
- Manifest reference: `https://docs.noctalia.dev/v4/development/plugins/manifest/`
- Bar widget: `https://docs.noctalia.dev/v4/development/plugins/bar-widget/`
- Panel: `https://docs.noctalia.dev/v4/development/plugins/panel/`
- Settings UI: `https://docs.noctalia.dev/v4/development/plugins/settings-ui/`
- Translations: `https://docs.noctalia.dev/v4/development/plugins/translations/`
- IPC: `https://docs.noctalia.dev/v4/development/plugins/ipc/`
- Plugin API: `https://docs.noctalia.dev/v4/development/plugins/api/`

## What Belongs In A Plugin

Per the official Noctalia docs, plugins are the right place for features that extend the shell without becoming core shell behavior. Good fits include:

- compositor-specific extras
- hardware-specific controls
- third-party integrations
- niche productivity tools
- alternative widgets or visualizations

For this repository, a plugin should extend the Noctalia UX cleanly rather than reimplement shell infrastructure.

## Repository Contract

Each plugin lives in its own top-level directory.

Expected files:

- `manifest.json`
- `README.md`
- `preview.png` or another supported preview image
- one or more QML entry points referenced by `manifest.json`

Optional files:

- `i18n/en.json` and other language files
- additional assets

Avoid committing personal runtime settings.

Official docs say user settings are stored under the installed plugin directory as `settings.json`; the local shell implementation loads and writes that file inside `~/.config/noctalia/plugins/<plugin-id-or-composite-key>/settings.json`.

Repository rule:

- do not publish a user-personal `settings.json`
- do not rely on repository `settings.json` for marketplace defaults
- if a plugin needs a versioned `settings.json` for local backend/dev tooling, keep it sanitized and make sure runtime defaults still come from `metadata.defaultSettings`

## Plugin Directory Shape

Official docs describe this general layout:

```text
your-plugin/
├── manifest.json
├── preview.png
├── Main.qml
├── BarWidget.qml
├── DesktopWidget.qml
├── ControlCenterWidget.qml
├── LauncherProvider.qml
├── Panel.qml
├── Settings.qml
├── i18n/
│   ├── en.json
│   └── es.json
└── README.md
```

Not every file is required. Only `manifest.json` is mandatory, and you need at least one entry point.

## Manifest Rules

The manifest is the runtime contract Noctalia uses to register and load the plugin.

### Required fields

According to the official manifest reference and the local `PluginRegistry.qml`, these fields are required:

- `id`
- `name`
- `version`
- `author`
- `description`
- `entryPoints`

### Required field rules

- `id` must match the plugin directory name.
- `id` should be lowercase kebab-case.
- `version` must match `x.y.z`.
- `entryPoints` must exist and contain at least one entry.

### Optional fields we should normally provide

- `minNoctaliaVersion`
- `license`
- `repository`
- `tags`
- `dependencies`
- `metadata`

The official docs still show examples with `minNoctaliaVersion: "3.6.0"`. For this repository, prefer the version actually targeted by the shell/runtime we are developing against.

### Entry points supported by official docs

- `main`
- `barWidget`
- `desktopWidget`
- `desktopWidgetSettings`
- `controlCenterWidget`
- `launcherProvider`
- `panel`
- `settings`

The official manifest reference also shows a complete example with all of these entry points declared together. Treat that as a capability map, not as a requirement to ship every entry point in every plugin.

### Metadata we should know about

`metadata.defaultSettings`

- seed values merged into `pluginApi.pluginSettings`
- user settings override these defaults at runtime

`metadata.commandPrefix`

- used by launcher-provider plugins
- defines the `>prefix` launcher command
- used by `pluginApi.toggleLauncher()`
- falls back to plugin ID if omitted

Official docs also note that `dependencies.plugins` exists, but dependency resolution is not implemented yet. Keep the field valid, but do not rely on Noctalia to install dependencies automatically.

### Safe manifest template

```json
{
  "id": "my-plugin",
  "name": "My Plugin",
  "version": "0.1.0",
  "minNoctaliaVersion": "4.6.6",
  "author": "Your Name",
  "license": "MIT",
  "repository": "https://github.com/youruser/noctalia-plugins",
  "description": "Short description of the plugin.",
  "entryPoints": {
    "main": "Main.qml",
    "barWidget": "BarWidget.qml",
    "panel": "Panel.qml",
    "settings": "Settings.qml"
  },
  "dependencies": {
    "plugins": []
  },
  "metadata": {
    "defaultSettings": {}
  }
}
```

## Entry Point Guidance

### `Main.qml`

Use this for background logic, IPC handlers, or orchestration that should not live inside the UI components. The official docs position `Main.qml` as the right place for background processing and IPC.

Our rule:

- UI stays in UI entry points
- execution logic stays in `Main.qml` or an external helper backend

### `BarWidget.qml`

The official bar widget docs require these properties:

- `property var pluginApi: null`
- `property ShellScreen screen`
- `property string widgetId: ""`
- `property string section: ""`
- `property int sectionWidgetIndex: -1`
- `property int sectionWidgetsCount: 0`

Use Noctalia style helpers for per-screen sizing:

- `Style.getCapsuleHeightForScreen(screenName)`
- `Style.getBarFontSizeForScreen(screenName)`

The docs also explicitly recommend supporting vertical bars.

The official bar widget docs also recommend:

- using an `Item` root with a centered visual capsule
- keeping the click target slightly larger than the visible content
- adding a background and outline border for visual consistency
- using per-screen style helpers instead of fixed global bar sizes

### `DesktopWidget.qml`

The official docs support `desktopWidget` as a first-class plugin entry point for content rendered on the desktop background. Use it when the feature belongs on the desktop itself rather than in the bar or in a panel.

If the plugin needs per-widget instance configuration, pair it with `desktopWidgetSettings` instead of trying to overload the generic plugin settings UI.

### `desktopWidgetSettings`

The official manifest reference includes `desktopWidgetSettings` as a separate entry point. Use it only for desktop-widget-specific configuration.

This is distinct from plugin-wide `settings`.

### `controlCenterWidget`

The official control center widget docs define this as a compact widget that appears inside the Control Center.

Required properties from the official docs:

- `property ShellScreen screen`
- `property var pluginApi: null`

Recommended pattern from the docs:

- use `NIconButtonHot`
- call `pluginApi.togglePanel(screen, this)` when opening a panel from the widget

Use this entry point for quick actions, not for heavy UI.

### `launcherProvider`

The official launcher provider docs define this entry point for custom launcher search sources and command handlers.

Typical responsibilities:

- expose launcher commands such as `>kaomoji`
- return search results via `getResults(searchText)`
- optionally provide browsable categories

This entry point pairs naturally with `metadata.commandPrefix` and IPC methods that call `pluginApi.toggleLauncher(screen)`.

### `Panel.qml`

The official panel docs require:

- `property var pluginApi: null`
- `readonly property var geometryPlaceholder: <content root>`
- `readonly property bool allowAttach: true`

`PluginPanelSlot.qml` in the shell confirms those properties are used at runtime for sizing and attachment behavior.

The official panel docs also recommend exposing:

- `property real contentPreferredWidth`
- `property real contentPreferredHeight`

And multiplying dimensions by `Style.uiScaleRatio` so panels respect the user’s UI scaling.

### `Settings.qml`

The official settings UI docs require:

- `property var pluginApi: null`
- `function saveSettings() { ... }`

The docs explicitly recommend a local state pattern:

- initialize editable values from `pluginApi.pluginSettings`
- fall back to `pluginApi.manifest.metadata.defaultSettings`
- only write back to `pluginApi.pluginSettings` inside `saveSettings()`

Do not mutate persisted settings directly during normal editing if the user should still be able to cancel.

The official settings UI docs also show that `entryPoints.settings` should normally be paired with `metadata.defaultSettings` in the manifest, so the editor has stable defaults before the first save.

### `i18n/*.json`

Official docs define the translation fallback order as:

1. current language file
2. `i18n/en.json`
3. key rendered as `!! key !!`

Always add `i18n/en.json` first if the plugin has any user-facing strings.

The official translations docs also state:

- translation files live under `i18n/`
- nested translation keys are supported
- plurals use the `_plural` suffix
- `pluginApi.currentLanguage` can be observed to react to language changes

Supported language codes listed in the docs include:

- `en`
- `es`
- `de`
- `fr`
- `it`
- `pt`
- `nl`
- `ru`
- `ja`
- `zh-CN`
- `tr`
- `uk-UA`

## Official `pluginApi` Surface

The official API reference documents the plugin API around properties, methods, and access to shell services.

### Important properties

- `pluginId`
- `pluginDir`
- `pluginSettings`
- `manifest`
- `currentLanguage`
- `mainInstance`
- `barWidget`
- `desktopWidget`
- `controlCenterWidget`
- `launcherProvider`
- `panelOpenScreen`

Two especially useful properties:

`pluginSettings`

- mutable settings object for the plugin
- usually starts from `metadata.defaultSettings`
- should be persisted with `pluginApi.saveSettings()`

`mainInstance`

- reference to instantiated `Main.qml`
- lets other entry points call functions defined in `Main.qml`
- is `null` when the plugin has no `main` entry point or it has not loaded yet

### Important methods

- `saveSettings()`
- `openPanel(screen, buttonItem?)`
- `closePanel(screen)`
- `togglePanel(screen, buttonItem?)`
- `openLauncher(screen)`
- `closeLauncher(screen)`
- `toggleLauncher(screen)`
- `tr(key, interpolations)`
- `trp(key, count, defaultSingular, defaultPlural, interpolations)`
- `hasTranslation(key)`
- `withCurrentScreen(callback)`

Practical guidance:

- use `openPanel(screen, this)` from clickable widgets when the panel should anchor near the trigger
- use `toggleLauncher(screen)` for launcher-provider plugins instead of manually manipulating launcher state
- use `trp()` for counted strings and define `<key>_plural` in translation files
- use `hasTranslation()` only for optional text paths, not as a replacement for a complete `en.json`

## Runtime Behavior Verified In `noctalia-shell`

These points come from the local shell implementation and are useful because they describe what actually runs.

### Installed location

Plugins are installed under:

```text
~/.config/noctalia/plugins/
```

The shell scans that directory for plugin folders containing `manifest.json`.

### Plugin state file

The shell stores plugin registry state in:

```text
~/.config/noctalia/plugins.json
```

That file tracks:

- enabled state
- plugin sources
- source URLs for installed plugins

### Registry source format

The shell fetches a custom source by cloning the git repository and sparse-checking out only `/registry.json`.

That means this repository must keep a valid root-level `registry.json`.

### Composite keys for custom sources

Official source plugins use plain IDs.

Custom source plugins may use a composite key in the form:

```text
<source-hash>:<plugin-id>
```

That is runtime behavior in `PluginRegistry.qml`. For authoring, continue using plain `id` in `manifest.json`; the shell adds the composite key internally.

### Settings persistence

The shell merges:

1. `manifest.metadata.defaultSettings`
2. loaded `settings.json`

User settings win over defaults.

### Translation loading

The shell loads the active language first and then English as fallback. This matches the official translation docs.

## IPC Pattern

The official IPC docs show that plugin IPC handlers should target namespaced IDs like:

```qml
IpcHandler {
  target: "plugin:my-plugin"
}
```

Important runtime rules:

- IPC handler arguments arrive as strings
- parse numeric values yourself
- use `pluginApi.withCurrentScreen(...)` when a command needs a `ShellScreen`

Official IPC guidance also states:

- handlers are typically registered in `Main.qml`
- each function on the `IpcHandler` becomes externally callable
- the target must be `plugin:<manifest.id>`
- the target must match the manifest ID exactly

Recommended patterns:

- panel plugin: `pluginApi.withCurrentScreen(screen => pluginApi.togglePanel(screen))`
- launcher provider: `pluginApi.withCurrentScreen(screen => pluginApi.toggleLauncher(screen))`

Example command:

```bash
qs -c noctalia-shell ipc call plugin:my-plugin toggle
```

For launcher providers, the official docs explicitly recommend using `toggleLauncher(screen)` because it handles both normal and overlay launcher modes and pre-fills the launcher with the manifest `commandPrefix`.

## Workflow For This Registry

When creating a new plugin in this repository:

1. Create a top-level plugin directory named exactly as the plugin `id`.
2. Add `manifest.json`.
3. Add the QML entry points referenced by the manifest.
4. Add `README.md`.
5. Add a preview image, preferably `preview.png`.
6. Add `i18n/en.json` if there are user-facing strings.
7. Run `node scripts/update-registry.js`.
8. Verify the new plugin appears in `registry.json`.

For local iteration before publication, the official getting-started guide also allows developing directly in `~/.config/noctalia/plugins/` or symlinking your worktree into that directory.

## Conventions For This Repository

These are not all official requirements, but we should keep them stable:

- prefer `README.md` inside each plugin directory
- prefer `preview.png` as the preview filename
- prefer `i18n/en.json` even if the plugin currently targets one language
- keep backend-heavy behavior out of `Panel.qml` and `BarWidget.qml`
- use `metadata.defaultSettings` from day one, even for small plugins
- if a plugin is planning-only, do not publish it in `registry.json`
- prefer the official entry point names exactly instead of inventing aliases

## Suggested Reading Order For New Plugins

When starting a new plugin, read the official docs in this order:

1. Overview
2. Getting Started
3. Manifest Reference
4. Only the entry point pages you actually plan to use
5. Settings UI
6. Translations
7. IPC
8. API Reference

This avoids designing a plugin UI before understanding the manifest contract and the injected runtime API.

## Maintenance Rule

The official docs are versioned and currently expose v4 as stable. Before starting a new plugin or updating this document, verify whether the relevant docs page has changed and whether the local `noctalia-shell` implementation still matches it.

If the docs and runtime disagree:

- trust the local shell runtime for behavior
- document the discrepancy here
- adjust the plugin scaffold to the runtime contract
