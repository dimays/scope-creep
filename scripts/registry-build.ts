#!/usr/bin/env bun
/**
 * The registry harvester. The sole writer of registry/*.json:
 *   - agents.json      generated from agents/*.md manifests (in-repo).
 *   - loops.json       generated from loops/*.md manifests (in-repo).
 *   - apps.json        reconciled from registration records; each app's referenced
 *                      manifest is validated to exist.
 *   - extensions.json  reconciled the same way.
 *
 * Output is deterministic (no timestamps) so `registry:build` + `git diff` is a
 * reliable "registries in sync?" check. Dependency-free: node built-ins only.
 * Run: `bun run registry:build`  (or `bun run registry:check` in CI).
 */
import { existsSync } from "node:fs";
import { readdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const SOURCE = "scripts/registry-build.ts — run `bun run registry:build`";

type Frontmatter = { name?: string; description?: string; status?: string; owner_agent?: string };

function parseFrontmatter(src: string): Frontmatter {
  const fm: Frontmatter = {};
  if (!src.startsWith("---")) return fm;
  const end = src.indexOf("\n---", 3);
  if (end === -1) return fm;
  let inMeta = false;
  for (const line of src.slice(3, end).split("\n")) {
    if (/^metadata:\s*$/.test(line)) {
      inMeta = true;
      continue;
    }
    const indented = /^\s{2,}([a-z_]+):\s*(.*)$/.exec(line);
    if (inMeta && indented) {
      if (indented[1] === "status") fm.status = indented[2].trim();
      else if (indented[1] === "owner_agent") fm.owner_agent = indented[2].trim();
      continue;
    }
    const top = /^([a-z_]+):\s*(.*)$/.exec(line);
    if (top) {
      inMeta = false;
      if (top[1] === "name") fm.name = top[2].trim();
      else if (top[1] === "description") fm.description = top[2].trim();
    }
  }
  return fm;
}

const warnings: string[] = [];

async function buildAgents() {
  const dir = join(ROOT, "agents");
  const files = (await readdir(dir)).filter((f) => f.endsWith(".md")).sort();
  return Promise.all(
    files.map(async (file) => {
      const fm = parseFrontmatter(await readFile(join(dir, file), "utf8"));
      return {
        name: fm.name ?? file.replace(/\.md$/, ""),
        kind: "core",
        status: fm.status ?? "unknown",
        description: fm.description ?? "",
        path: `agents/${file}`,
      };
    }),
  );
}

async function buildLoops() {
  const dir = join(ROOT, "loops");
  const files = (await readdir(dir)).filter((f) => f.endsWith(".md") && f !== "README.md").sort();
  return Promise.all(
    files.map(async (file) => {
      const fm = parseFrontmatter(await readFile(join(dir, file), "utf8"));
      return {
        name: fm.name ?? file.replace(/\.md$/, ""),
        kind: "loop",
        status: fm.status ?? "unknown",
        description: fm.description ?? "",
        owner_agent: fm.owner_agent ?? "",
        path: `loops/${file}`,
      };
    }),
  );
}

async function reconcile(file: string, key: string): Promise<Array<Record<string, unknown>>> {
  const path = join(ROOT, "registry", file);
  const current = JSON.parse(await readFile(path, "utf8")) as Record<string, unknown>;
  const items = Array.isArray(current[key]) ? (current[key] as Array<Record<string, unknown>>) : [];
  for (const item of items) {
    const manifest = item.manifest;
    if (typeof manifest === "string" && !existsSync(join(ROOT, manifest))) {
      warnings.push(`${file}: '${item.name}' references a missing manifest: ${manifest}`);
    }
  }
  return items;
}

async function write(file: string, key: string, values: unknown[]) {
  const body = { _generated: true, _source: SOURCE, schema_version: "1.0.0", [key]: values };
  await writeFile(join(ROOT, "registry", file), `${JSON.stringify(body, null, 2)}\n`);
}

async function main() {
  const agents = await buildAgents();
  await write("agents.json", "agents", agents);
  const loops = await buildLoops();
  await write("loops.json", "loops", loops);
  await write("apps.json", "apps", await reconcile("apps.json", "apps"));
  await write("extensions.json", "extensions", await reconcile("extensions.json", "extensions"));

  console.log(
    `registry:build — ${agents.length} agents, ${loops.length} loops generated; apps/extensions reconciled.`,
  );
  if (warnings.length > 0) {
    console.warn(`\n${warnings.length} warning(s):`);
    for (const w of warnings) console.warn(`  - ${w}`);
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
