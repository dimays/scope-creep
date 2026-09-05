#!/usr/bin/env bun
/**
 * Validates every work/NNN-*.md against the work-item schema (see work/README.md).
 * Fails (exit 1) on any missing required field or invalid enum value.
 * Run: `bun run work:check`  (also runs in CI).
 */
import { readdir, readFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const WORK = join(ROOT, "work");

const REQUIRED = ["id", "title", "type", "status", "priority", "owner", "spec", "created", "updated"];
const ENUMS: Record<string, string[]> = {
  type: ["feature", "bug", "debt", "chore"],
  status: ["proposed", "active", "blocked", "done", "superseded", "dropped"],
  priority: ["high", "medium", "low"],
};

function parseFlatFrontmatter(src: string): Record<string, string> {
  const fm: Record<string, string> = {};
  if (!src.startsWith("---")) return fm;
  const end = src.indexOf("\n---", 3);
  if (end === -1) return fm;
  for (const line of src.slice(3, end).split("\n")) {
    const match = /^([a-z_]+):\s*(.*)$/.exec(line);
    if (match) fm[match[1]] = match[2].trim();
  }
  return fm;
}

const errors: string[] = [];

const files = (await readdir(WORK))
  .filter((f) => f.endsWith(".md") && f !== "README.md")
  .sort();

for (const file of files) {
  const fm = parseFlatFrontmatter(await readFile(join(WORK, file), "utf8"));
  for (const key of REQUIRED) {
    if (!fm[key]) errors.push(`${file}: missing required field '${key}'`);
  }
  for (const [key, allowed] of Object.entries(ENUMS)) {
    if (fm[key] && !allowed.includes(fm[key])) {
      errors.push(`${file}: '${key}' is '${fm[key]}', expected one of ${allowed.join(", ")}`);
    }
  }
}

if (errors.length > 0) {
  console.error(`work:check — ${errors.length} problem(s):`);
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}
console.log(`work:check — ${files.length} work items OK.`);
