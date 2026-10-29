const fs = require("fs");
const path = require("path");

const cfgPath = process.argv[2] || ".github/config/extract/patchouli.json";
const cfg = JSON.parse(readJson(cfgPath));
const ASSETS = path.resolve(cfg.kubejs_assets);
const TRANS = new Set(cfg.translatable_keys || []);
const SKIP = new Set(["en_us", ...(cfg.skip_relpaths || [])]);
const LOCALES = new Set(cfg.locales || []);
const BOOKS = cfg.books || [];

function readJson(p) {
  return fs.readFileSync(p, "utf8").replace(/^﻿/, "");
}

function* strPaths(obj, p = []) {
  if (obj && typeof obj === "object") {
    if (Array.isArray(obj)) {
      for (let i = 0; i < obj.length; i++) yield* strPaths(obj[i], [...p, i]);
    } else {
      for (const k of Object.keys(obj)) yield* strPaths(obj[k], [...p, k]);
    }
  } else if (typeof obj === "string") {
    yield [p, obj];
  }
}

function setp(obj, p, val) {
  for (const x of p.slice(0, -1)) obj = obj[x];
  obj[p[p.length - 1]] = val;
}

function indentOf(text) {
  for (const line of text.split("\n")) {
    if (line.startsWith("\t")) return "\t";
    if (line.startsWith(" ")) return line.length - line.trimStart().length;
  }
  return 4;
}

function* walk(dir) {
  if (!fs.existsSync(dir)) return;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) yield* walk(p);
    else if (e.name.endsWith(".json")) yield p;
  }
}

let roots;
if (process.argv[3]) {
  roots = [path.resolve(process.argv[3])];
} else if (BOOKS.length) {
  roots = BOOKS.map((b) => {
    const i = b.indexOf("/");
    return path.join(ASSETS, b.slice(0, i), "patchouli_books", b.slice(i + 1));
  });
} else {
  roots = [];
  for (const ns of fs.readdirSync(ASSETS, { withFileTypes: true })) {
    const books = path.join(ASSETS, ns.name, "patchouli_books");
    if (!ns.isDirectory() || !fs.existsSync(books)) continue;
    for (const book of fs.readdirSync(books)) roots.push(path.join(books, book));
  }
}

let changed = 0;
for (const root of roots) {
  for (const f of walk(root)) {
    const rel = path.relative(root, f).split(path.sep);
    if (rel.length < 2) continue;
    const loc = rel[0];
    const sub = rel.slice(1);
    if (SKIP.has(loc) || !LOCALES.has(loc) || SKIP.has(sub[0])) continue;
    const en = path.join(root, "en_us", ...sub);
    if (!fs.existsSync(en)) continue;

    const locText = readJson(f);
    const locObj = JSON.parse(locText.replace(/^﻿/, ""));
    const enObj = JSON.parse(readJson(en));
    const enStrs = new Map();
    for (const [p, v] of strPaths(enObj)) enStrs.set(JSON.stringify(p), v);
    for (const [p, lv] of strPaths(locObj)) {
      const ev = enStrs.get(JSON.stringify(p));
      const last = p[p.length - 1];
      if (
        typeof last === "string" &&
        TRANS.has(last) &&
        lv.trim() &&
        typeof ev === "string" &&
        ev.trim()
      )
        setp(enObj, p, lv);
    }
    if (JSON.stringify(enObj) === JSON.stringify(locObj)) continue;
    const nl = locText.endsWith("\n") ? "\n" : "";
    fs.writeFileSync(f, JSON.stringify(enObj, null, indentOf(locText)) + nl, "utf8");
    changed++;
    console.log(`normalized ${f}`);
  }
}
console.log(`${changed} file(s) normalized`);
