# Noctalia Plugin Publishing Checklist

Use this checklist when a plugin is about to be published in this repository.

For implementation guidance, read [docs/noctalia-plugin-development-guide.md](/home/alessandro/Pessoal/noctalia-plugins/docs/noctalia-plugin-development-guide.md:1).

## Required Before Publish

- plugin directory name matches `manifest.id`
- `manifest.json` parses as valid JSON
- `version` uses `x.y.z`
- `entryPoints` exists
- every referenced entry point file actually exists
- plugin has a `README.md`
- plugin has a preview image, preferably `preview.png`
- plugin does not publish a personal `settings.json`
- `node scripts/update-registry.js` was run
- `registry.json` includes the plugin

## Manifest Checks

- required manifest fields are present: `id`, `name`, `version`, `author`, `description`, `entryPoints`
- `minNoctaliaVersion` matches the runtime we target
- `repository` points to the correct repository
- `metadata.defaultSettings` exists when the plugin has configurable behavior
- if `settings.json` exists in the repo for local tooling, it is sanitized and does not replace `metadata.defaultSettings`
- `metadata.commandPrefix` is set when the plugin has a launcher provider and needs a custom prefix
- `dependencies.plugins` is valid JSON if present

## Entry Point Checks

### `BarWidget.qml`

- exposes `pluginApi`
- exposes `screen`
- exposes `widgetId`
- exposes `section`
- exposes `sectionWidgetIndex`
- exposes `sectionWidgetsCount`
- uses per-screen sizing helpers where relevant

### `Panel.qml`

- exposes `pluginApi`
- defines `geometryPlaceholder`
- defines `allowAttach`
- defines preferred size if the panel is not trivial

### `Settings.qml`

- exposes `pluginApi`
- defines `saveSettings()`
- uses local edit state before persisting values
- writes back through `pluginApi.pluginSettings`
- persists through `pluginApi.saveSettings()`

### `Main.qml`

- uses `plugin:<manifest.id>` in any `IpcHandler`
- keeps orchestration/background logic out of UI components

## Translation Checks

- `i18n/en.json` exists if the plugin shows user-facing text
- translation keys used in QML exist in `en.json`
- pluralized strings use `<key>` and `<key>_plural`
- optional extra languages use official Noctalia language codes

## Repository Checks

- plugin `README.md` explains scope and limitations
- any external runtime dependency is documented in the plugin `README.md`
- planning-only plugins are not published
- root `README.md` plugin list is updated if needed

## Optional Runtime Validation

If you are validating the plugin locally in Noctalia, check:

- plugin appears in the Plugins tab
- plugin can be enabled
- bar widget or other entry point loads without obvious errors
- settings dialog opens if `settings` exists
- panel opens if `panel` exists
- IPC command works if `Main.qml` exposes handlers

## Release Handoff

Before commit or PR:

- run `git status --short`
- verify only intended plugin and registry changes are included
- make sure generated `registry.json` is committed with the plugin changes
