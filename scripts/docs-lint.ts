#!/usr/bin/env bun
/**
 * Doc-integrity linter (doc-standards §8). Fails (exit 1) on:
 *   - a dangling wiki-link — `[[target]]` that resolves to no manifest `name` or work `id`;
 *   - a manifest missing a required field (name / description / metadata.type);
 *   - a hand-seeded registry (`_generated: false`) or an agents/loops registry out of
 *     sync with the agents/ or loops/ manifests;
 *   - an `owner_agent` (in agents/ or loops/) that doesn't resolve to a real agent
 *     (or the `human-owner` sentinel) — every "owned-by" cross-link must be trustworthy.
 * Warns (does not fail) on a stale `last_verified`. Run: `bun run docs:lint` (also in CI).
 *
 * Registry *content* drift is covered by `registry:check` (full rebuild + diff), which
 * runs alongside this in CI; here we only guard the generated flag + the agents/loops sets.
 */
import { readdir, readFile } from "node:fs/promises";
import { basename, dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const FRESH_DAYS = 60;
const MANIFEST_DIRS = [
  "charter",
  "standards",
  "standards/adr",
  "product",
  "loops",
  "agents",
  "agents/employees",
  "agents/templates",
  "ledger",
  "environments",
];

type Fm = { top: Record<string, string>; meta: Record<string, string> };

function parseFrontmatter(src: string): Fm {
  const top: Record<string, string> = {};
  const meta: Record<string, string> = {};
  if (!src.startsWith("---")) return { top, meta };
  const end = src.indexOf("\n---", 3);
  if (end === -1) return { top, meta };
  let inMeta = false;
  for (const line of src.slice(3, end).split("\n")) {
    if (/^metadata:\s*$/.test(line)) {
      inMeta = true;
      continue;
    }
    const nested = /^\s{2,}([a-z_]+):\s*(.*)$/.exec(line);
    if (inMeta && nested) {
      meta[nested[1]] = nested[2].trim();
      continue;
    }
    const top_ = /^([a-z_]+):\s*(.*)$/.exec(line);
    if (top_) {
      inMeta = false;
      top[top_[1]] = top_[2].trim();
    }
  }
  return { top, meta };
}

/** Every `[[target]]` (alias stripped) in a body, ignoring code spans/fences. */
function wikilinks(body: string): string[] {
  const clean = body.replace(/```[\s\S]*?```/g, "").replace(/`[^`]*`/g, "");
  return [...clean.matchAll(/\[\[([^\]]+)\]\]/g)].map((m) => m[1].split("|")[0].trim());
}

async function allMarkdown(dir: string): Promise<string[]> {
  const out: string[] = [];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    if (entry.name === "node_modules" || entry.name === ".git") continue;
    const full = join(dir, entry.name);
    if (entry.isDirectory()) out.push(...(await allMarkdown(full)));
    else if (entry.name.endsWith(".md")) out.push(full);
  }
  return out;
}

const OWNER_SENTINEL = "human-owner";

const errors: string[] = [];
const warnings: string[] = [];
const now = Date.now();

const mdFiles = await allMarkdown(ROOT);

// Pass 1 — the set of resolvable targets: every manifest `name` + every work `id`.
const validTargets = new Set<string>();
for (const file of mdFiles) {
  const { top } = parseFrontmatter(await readFile(file, "utf8"));
  if (top.name) validTargets.add(top.name);
  if (top.id) validTargets.add(top.id);
}

// The set of real agents (by manifest filename — the convention agents.json's own
// symmetry check below relies on). Used to validate every `owner_agent`.
const agentNames = new Set(
  (await readdir(join(ROOT, "agents")))
    .filter((f) => f.endsWith(".md") && f !== "README.md")
    .map((f) => f.replace(/\.md$/, "")),
);

// Pass 2 — per-file checks.
for (const file of mdFiles) {
  const rel = relative(ROOT, file);
  const src = await readFile(file, "utf8");
  const { top, meta } = parseFrontmatter(src);
  const body = src.startsWith("---") ? src.slice(src.indexOf("\n---", 3) + 4) : src;

  // Wiki-link resolution (the ADR template carries placeholder [[adr-NNN]] syntax).
  if (basename(file) !== "000-template.md") {
    for (const target of wikilinks(body)) {
      if (!validTargets.has(target)) {
        errors.push(`${rel}: dangling wiki-link [[${target}]]`);
      }
    }
  }

  // Required manifest fields (README indexes + the template are exempt).
  const dir = dirname(rel);
  const isManifest =
    MANIFEST_DIRS.includes(dir) && basename(file) !== "README.md" && basename(file) !== "000-template.md";
  if (isManifest) {
    if (!top.name) errors.push(`${rel}: missing 'name'`);
    if (!top.description) errors.push(`${rel}: missing 'description'`);
    if (!meta.type) errors.push(`${rel}: missing 'metadata.type'`);
    if (meta.last_verified) {
      const days = Math.floor((now - Date.parse(meta.last_verified)) / 86_400_000);
      if (Number.isFinite(days) && days > FRESH_DAYS) {
        warnings.push(`${rel}: last_verified is ${days}d old (> ${FRESH_DAYS})`);
      }
    }
  }

  // owner_agent must resolve to a real agent (or the human-owner sentinel) — scoped to
  // agents/ (incl. employees/templates) and loops/, whose owner_agent is a load-bearing
  // cross-link.
  if (dir === "agents" || dir === "agents/employees" || dir === "agents/templates" || dir === "loops") {
    const owner = meta.owner_agent;
    if (owner && owner !== OWNER_SENTINEL && !agentNames.has(owner)) {
      errors.push(`${rel}: owner_agent '${owner}' does not resolve to a real agent (or '${OWNER_SENTINEL}')`);
    }
  }
}

// Pass 3 — registry integrity.
for (const file of [
  "agents.json",
  "employee-templates.json",
  "loops.json",
  "apps.json",
  "extensions.json",
]) {
  let json: { _generated?: boolean; agents?: Array<{ name: string }> };
  try {
    json = JSON.parse(await readFile(join(ROOT, "registry", file), "utf8"));
  } catch {
    errors.push(`registry/${file}: missing or unparseable`);
    continue;
  }
  if (json._generated !== true) {
    errors.push(`registry/${file}: not generated (_generated !== true) — run registry:build`);
  }
}
try {
  const agentsJson = JSON.parse(await readFile(join(ROOT, "registry", "agents.json"), "utf8"));
  const inRegistry = new Set((agentsJson.agents ?? []).map((a: { name: string }) => a.name));
  // Core/functional agents live flat in agents/; employees in agents/employees/.
  const onDisk = new Set<string>();
  for (const rel of ["agents", "agents/employees"]) {
    for (const f of await readdir(join(ROOT, rel))) {
      if (f.endsWith(".md") && f !== "README.md") onDisk.add(f.replace(/\.md$/, ""));
    }
  }
  for (const name of onDisk) {
    if (!inRegistry.has(name)) errors.push(`registry/agents.json: missing agent '${name}' — run registry:build`);
  }
  for (const name of inRegistry) {
    if (!onDisk.has(name as string)) {
      errors.push(`registry/agents.json: lists '${name}' with no manifest under agents/ or agents/employees/`);
    }
  }
} catch {
  // agents.json failure already reported above.
}
try {
  const loopsJson = JSON.parse(await readFile(join(ROOT, "registry", "loops.json"), "utf8"));
  const inRegistry = new Set((loopsJson.loops ?? []).map((l: { name: string }) => l.name));
  const onDisk = new Set(
    (await readdir(join(ROOT, "loops")))
      .filter((f) => f.endsWith(".md") && f !== "README.md")
      .map((f) => f.replace(/\.md$/, "")),
  );
  for (const name of onDisk) {
    if (!inRegistry.has(name)) errors.push(`registry/loops.json: missing loop '${name}' — run registry:build`);
  }
  for (const name of inRegistry) {
    if (!onDisk.has(name as string)) {
      errors.push(`registry/loops.json: lists '${name}' with no loops/${name}.md`);
    }
  }
} catch {
  // loops.json failure already reported above.
}

for (const w of warnings) console.warn(`  warn: ${w}`);
if (errors.length > 0) {
  console.error(`docs:lint — ${errors.length} problem(s):`);
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
console.log(
  `docs:lint — ${mdFiles.length} docs OK (${validTargets.size} link targets, ${warnings.length} warning(s)).`,
);
