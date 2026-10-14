// Builds the public site from site/: each page (an artifact source, no <html>/<head>) wrapped into a
// whole document, with what changes as omaseed moves read from its GitHub repo: the version (its
// latest release) and "What's next" (its open issues). No dependencies; Node 18+. Adapted from
// omabox-site's build.mjs.
//
//   node build.mjs              into dist/, for omaseed.app; GITHUB_TOKEN, if set, is used for the API
//   SITE_URL=https://x.pages.dev node build.mjs
//                               for another address, and keeps search engines out: anything but
//                               omaseed.app gets noindex
//
// If GitHub can't be reached, each page keeps what its source has (the version, the issue list
// between the <!-- next --> markers) and the build says so.
//
// The theme colours in the home page come from Omarchy itself, which CI doesn't have: run
// `node themes.mjs` on an Omarchy machine to refresh them.

import { cp, mkdir, readFile, rm, writeFile } from "node:fs/promises";

const REPO = "diogochaves/omaseed";
const HOME = "https://omaseed.app";
const SITE = (process.env.SITE_URL || HOME).replace(/\/+$/, "");
const OUT = "dist";
// "What's next": open issues with this label, newest first; with none labelled, the newest open
// enhancements. Titles lose their spec references ("(docs/24)"), nothing else.
const NEXT_LABEL = "next", NEXT_COUNT = 4;

const PAGES = [
  { src: "omaseed.html", out: "index.html", path: "/", home: true,
    title: "omaseed: a native torrent client for Omarchy",
    desc: "Torrents, finally at home on Omarchy. A native client for one qBittorrent server or many: your theme, your keys, your seeding history." },
];

const esc = s => String(s).replace(/[&<>"]/g, ch => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[ch]));
const headers = { accept: "application/vnd.github+json", "user-agent": "omaseed-site-build" };
if (process.env.GITHUB_TOKEN) headers.authorization = `Bearer ${process.env.GITHUB_TOKEN}`;
async function api(path) {
  const r = await fetch(`https://api.github.com${path}`, { headers });
  if (!r.ok) throw new Error(`${path}: HTTP ${r.status}`);
  return r.json();
}

// The latest release, "v0.1.0" → "0.1.0"; every page shows it in each <span class="ver">.
async function latestVersion() {
  const v = String((await api(`/repos/${REPO}/releases/latest`)).tag_name || "").replace(/^v/, "");
  if (!/^\d+\.\d+\.\d+$/.test(v)) throw new Error(`unexpected tag ${JSON.stringify(v)}`);
  return v;
}

async function nextItems() {
  const open = (await api(`/repos/${REPO}/issues?state=open&per_page=100&sort=created&direction=desc`)).filter(i => !i.pull_request);
  const has = name => i => i.labels.some(l => l.name === name);
  const picked = (open.some(has(NEXT_LABEL)) ? open.filter(has(NEXT_LABEL)) : open.filter(has("enhancement"))).slice(0, NEXT_COUNT);
  if (!picked.length) throw new Error("no open issues to show");
  return picked.map(i => `      <li><span>#${i.number}</span><a href="${esc(i.html_url)}">${esc(i.title.replace(/\s*\(docs\/\d+\)/g, "").trim())}</a></li>`);
}

const head = page => `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>${esc(page.title)}</title>
<meta name="description" content="${esc(page.desc)}">
<meta name="theme-color" content="#13141c">
${SITE === HOME ? "" : '<meta name="robots" content="noindex">\n'}<link rel="canonical" href="${SITE}${page.path}">
<link rel="icon" href="media/icon.svg" type="image/svg+xml">
<meta property="og:type" content="website">
<meta property="og:url" content="${SITE}${page.path}">
<meta property="og:title" content="${esc(page.title)}">
<meta property="og:description" content="${esc(page.card || page.desc)}">
${page.home ? `<script type="application/ld+json">${JSON.stringify({
  "@context": "https://schema.org", "@type": "SoftwareApplication", name: "omaseed", url: `${SITE}/`,
  description: "A native torrent client for Omarchy, for one qBittorrent server or many.",
  applicationCategory: "UtilitiesApplication", operatingSystem: "Linux (Omarchy)", softwareVersion: version,
  license: "https://opensource.org/licenses/MIT", codeRepository: `https://github.com/${REPO}`,
  offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
})}</script>\n` : ""}`;

const home = await readFile("site/omaseed.html", "utf8");
let version = home.match(/<span class="ver">([^<]+)<\/span>/)?.[1];
if (!version) throw new Error('site/omaseed.html: no <span class="ver"> with the version');
try { version = await latestVersion(); console.log(`version: ${version}`); }
catch (e) { console.warn(`version: kept ${version} from site/omaseed.html (${e.message})`); }
let next = null;
try { next = await nextItems(); console.log(`what's next: ${next.length} issues`); }
catch (e) { console.warn(`what's next: kept the list in site/omaseed.html (${e.message})`); }

await rm(OUT, { recursive: true, force: true });
await mkdir(OUT, { recursive: true });

for (const page of PAGES) {
  let src = await readFile(`site/${page.src}`, "utf8");
  src = src.replaceAll(/(<span class="ver">)[^<]+/g, `$1${version}`);
  if (next) src = src.replace(/<!-- next[^>]*-->[^]*?<!-- \/next -->/, () => `<!-- next -->\n${next.join("\n")}\n      <!-- /next -->`);
  const cut = src.indexOf("<!-- body -->");   // the <title>, fonts and <style> go in <head>; the rest is the body
  if (cut < 0) throw new Error(`site/${page.src}: no <!-- body --> marker`);
  const doc = `${head(page)}${src.slice(0, cut).replace(/<title>[^<]*<\/title>\n?/, "")}</head>\n<body>\n${src.slice(cut + 13).trimStart()}\n</body>\n</html>\n`;
  await writeFile(`${OUT}/${page.out}`, doc);
  console.log(`built ${OUT}/${page.out}`);
}

await mkdir(`${OUT}/media`, { recursive: true });
await cp("site/media", `${OUT}/media`, { recursive: true, filter: src => !src.endsWith("README.md") });
if (SITE !== HOME) await writeFile(`${OUT}/_headers`, "/*\n  X-Robots-Tag: noindex\n");
// functions/_middleware.js (the www redirect) runs for these paths only, not for the media
await writeFile(`${OUT}/_routes.json`, JSON.stringify({ version: 1, include: ["/*"], exclude: ["/media/*"] }) + "\n");
await writeFile(`${OUT}/robots.txt`, SITE === HOME ? `User-agent: *\nAllow: /\nSitemap: ${HOME}/sitemap.xml\n` : "User-agent: *\nDisallow: /\n");
const today = new Date().toISOString().slice(0, 10);
if (SITE === HOME) await writeFile(`${OUT}/sitemap.xml`, `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">${PAGES.map(p => `<url><loc>${HOME}${p.path}</loc><lastmod>${today}</lastmod></url>`).join("")}</urlset>\n`);
console.log(`built ${OUT}/ for ${SITE}${SITE === HOME ? "" : " (noindex)"}`);
