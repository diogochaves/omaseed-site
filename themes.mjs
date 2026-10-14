// Writes every bundled Omarchy theme's colours into site/omaseed.html, between the /* themes */
// markers, so the page's theme switch shows the same colours omaseed reads. Run it on a machine
// with Omarchy after an Omarchy update adds or changes a theme; the build doesn't (CI has no
// Omarchy). No dependencies.
//
//   node themes.mjs [themes dir]     default /usr/share/omarchy/themes

import { readdir, readFile, writeFile } from "node:fs/promises";

const DIR = process.argv[2] || "/usr/share/omarchy/themes";
const PAGE = "site/omaseed.html";
// The keys the page uses, and what fills one a theme leaves out. orange ← yellow is omaseed's own
// rule (ThemeReader.cpp); the others keep a theme readable when it skips a shade.
const KEYS = ["accent", "selection", "muted", "background", "dark_background", "darker_background",
  "lighter_background", "foreground", "dark_foreground", "light_foreground", "bright_foreground",
  "red", "yellow", "orange", "green", "cyan", "blue", "magenta"];
const FALLBACK = { orange: "yellow", lighter_background: "background", darker_background: "dark_background",
  light_foreground: "foreground", bright_foreground: "foreground", dark_foreground: "muted", selection: "muted" };

const themes = {};
for (const name of (await readdir(DIR)).sort()) {
  let toml;
  try { toml = await readFile(`${DIR}/${name}/colors.toml`, "utf8"); } catch { continue; }
  const c = Object.fromEntries([...toml.matchAll(/^(\w+)\s*=\s*"([^"]*)"/gm)].map(m => [m[1], m[2].toLowerCase()]));
  for (const k of KEYS) if (!c[k] && FALLBACK[k]) c[k] = c[FALLBACK[k]];
  const missing = KEYS.filter(k => !/^#[0-9a-f]{6}$/.test(c[k] || ""));
  if (missing.length) { console.warn(`${name}: no ${missing.join(", ")}, left out`); continue; }
  const label = name.split("-").map(w => w[0].toUpperCase() + w.slice(1)).join(" ");
  themes[name] = { label, mode: c.mode === "light" ? "light" : "dark", ...Object.fromEntries(KEYS.map(k => [k, c[k]])) };
}
if (!themes["tokyo-night"] || !themes.lupine) throw new Error(`${DIR}: Tokyo Night and Lupine are the page's defaults and must be there`);

const block = `/* themes: written by themes.mjs from ${DIR} */\nconst THEMES = ${JSON.stringify(themes)};\n/* /themes */`;
const page = await readFile(PAGE, "utf8");
if (!/\/\* themes[^]*?\/\* \/themes \*\//.test(page)) throw new Error(`${PAGE}: no /* themes */ markers`);
await writeFile(PAGE, page.replace(/\/\* themes[^]*?\/\* \/themes \*\//, () => block));
console.log(`${Object.keys(themes).length} themes into ${PAGE}`);
