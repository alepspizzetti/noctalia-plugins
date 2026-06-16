const fs = require("fs");
const path = require("path");

const root = process.cwd();
const entries = fs.readdirSync(root, { withFileTypes: true });
const plugins = [];

for (const entry of entries) {
  if (!entry.isDirectory() || entry.name.startsWith(".") || entry.name === "scripts") {
    continue;
  }

  const manifestPath = path.join(root, entry.name, "manifest.json");

  if (!fs.existsSync(manifestPath)) {
    continue;
  }

  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));

  plugins.push({
    id: manifest.id,
    name: manifest.name,
    version: manifest.version,
    official: false,
    author: manifest.author,
    description: manifest.description,
    repository: manifest.repository,
    minNoctaliaVersion: manifest.minNoctaliaVersion,
    license: manifest.license,
    tags: manifest.tags || [],
    lastUpdated: new Date().toISOString()
  });
}

plugins.sort((a, b) => a.id.localeCompare(b.id));

fs.writeFileSync(
  path.join(root, "registry.json"),
  `${JSON.stringify({ version: 1, plugins }, null, 2)}\n`
);
