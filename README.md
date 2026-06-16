# Noctalia Plugins

Personal plugin registry for Noctalia Shell.

## Installation

1. Open Noctalia Settings.
2. Go to Plugins -> Sources.
3. Click Add custom repository.
4. Add this repository URL.
5. Install plugins from the Available tab.

## Plugins

No plugins yet.

## Development

Each plugin lives in its own directory and must include:

- `manifest.json`
- `README.md`
- `preview.png`
- one or more QML entry points

The `registry.json` file is the index consumed by Noctalia.

When you add a plugin folder with a valid `manifest.json`, run:

```bash
node scripts/update-registry.js
```
