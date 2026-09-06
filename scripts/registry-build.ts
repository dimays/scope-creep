#!/usr/bin/env bun
/**
 * The registry harvester. The sole writer of registry/*.json:
 *   - agents.json      generated from agents/*.md, agents/employees/*.md manifests
 *                      (executive `core` agents, standing `function` agents, and
 *                      `employee` agents — all in-repo; the `kind` distinguishes the
 *                      tier, see [[adr-020]]).
 *   - employee-templates.json  generated from agents/templates/*.md manifests
 *                      (each carries the `owner_agent` executive it hangs under, so
 *                      the org view can group templates per exec — [[adr-020]]).
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

type Frontmatter = {
  name?: string;
  description?: string;
  status?: string;
  owner_agent?: string;
  // Employee/template fields (top-level keys; optional):
  kind?: string;
  reports_to?: string;
  template?: string;
  default_model?: string;
  skills?: string;
};

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
      else if (top[1] === "kind") fm.kind = top[2].trim();
      else if (top[1] === "reports_to") fm.reports_to = top[2].trim();
      else if (top[1] === "template") fm.template = top[2].trim();
      else if (top[1] === "default_model") fm.default_model = top[2].trim();
      else if (top[1] === "skills") fm.skills = top[2].trim();
    }
  }
  return fm;
}

/** Split a comma-separated frontmatter list into a trimmed string[]. */
function parseList(raw: string | undefined): string[] {
  if (!raw) return [];
  return raw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

const warnings: string[] = [];

/** Read the .md manifests in a directory (non-recursive), skipping READMEs. */
async function readManifests(relDir: string) {
  const dir = join(ROOT, relDir);
  if (!existsSync(dir)) return [];
  const files = (await readdir(dir))
    .filter((f) => f.endsWith(".md") && f !== "README.md")
    .sort();
  return Promise.all(
    files.map(async (file) => ({
      file,
      relPath: `${relDir}/${file}`,
      fm: parseFrontmatter(await readFile(join(dir, file), "utf8")),
    })),
  );
}

async function buildAgents() {
  // Core/functional agents live flat in agents/; employees live in agents/employees/.
  const core = await readManifests("agents");
  const employees = await readManifests("agents/employees");
  const out: Array<Record<string, unknown>> = [];
  for (const { file, relPath, fm } of core) {
    // Flat agents/ holds two tiers: executives (`core`) and standing `function`
    // agents (qa-tester, git-manager). The manifest's `kind` decides; default `core`.
    out.push({
      name: fm.name ?? file.replace(/\.md$/, ""),
      kind: fm.kind ?? "core",
      status: fm.status ?? "unknown",
      description: fm.description ?? "",
      path: relPath,
    });
  }
  for (const { file, relPath, fm } of employees) {
    const name = fm.name ?? file.replace(/\.md$/, "");
    out.push({
      name,
      kind: fm.kind ?? "employee",
      status: fm.status ?? "unknown",
      description: fm.description ?? "",
      reports_to: fm.reports_to ?? "",
      template: fm.template ?? "",
      path: relPath,
    });
    if (!fm.reports_to) warnings.push(`agents.json: employee '${name}' has no reports_to`);
    if (!fm.template) warnings.push(`agents.json: employee '${name}' has no template`);
  }
  // Deterministic order: executives, then standing functions, then employees; name-tiebroken.
  const rank: Record<string, number> = { core: 0, function: 1, employee: 2 };
  return out.sort(
    (a, b) =>
      (rank[a.kind as string] ?? 9) - (rank[b.kind as string] ?? 9) ||
      String(a.name).localeCompare(String(b.name)),
  );
}

async function buildTemplates() {
  const templates = await readManifests("agents/templates");
  return templates.map(({ file, relPath, fm }) => ({
    name: fm.name ?? file.replace(/\.md$/, ""),
    kind: "template",
    status: fm.status ?? "unknown",
    description: fm.description ?? "",
    // The executive this template hangs under — lets the org view render the
    // per-exec "types of employees I can summon" catalog ([[adr-020]]).
    owner_agent: fm.owner_agent ?? "",
    default_model: fm.default_model ?? "",
    skills: parseList(fm.skills),
    path: relPath,
  }));
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
  const templates = await buildTemplates();
  await write("employee-templates.json", "templates", templates);
  const loops = await buildLoops();
  await write("loops.json", "loops", loops);
  await write("apps.json", "apps", await reconcile("apps.json", "apps"));
  await write("extensions.json", "extensions", await reconcile("extensions.json", "extensions"));

  console.log(
    `registry:build — ${agents.length} agents, ${templates.length} employee templates, ${loops.length} loops generated; apps/extensions reconciled.`,
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
