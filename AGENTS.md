# omaseed-site: instructions for agents

The site for omaseed (omaseed.app). Read `DIRECTION.md` first: what the page says, the references,
what is not claimed yet. Diogo is the owner; he says what changes.

- Nothing is published, pushed or put on a domain without Diogo asking. Drafts are private artifacts.
- The look of the app comes from `~/code/omarchy/omaseed/docs/05-ui-spec-v2.html` and the real
  screenshots in `omaseed/docs/screenshots/`. Read them; never edit omaseed's spec files.
- Any number on the page (memory, CPU, counts) is measured and its method written down, or it is not
  on the page. Demo data in the interactive mock is labelled as demo data.
- Anything that opens a window (running omaseed, screenshots) goes through omabox (load the omabox
  skill). The qBittorrent at :8080 is Diogo's real library: never contact it. Use :8081.

## Layout (as omabox-site)

- `site/omaseed.html`: the home page, as an **artifact source**: no `<!doctype>`, `<html>`, `<head>`
  or `<body>`. `<title>`, the font links and `<style>` come first, then a `<!-- body -->` marker.
  It holds the playable copy of the main window (library, details, seed console, the keys) and
  every chart, drawn from the demo data in its script.
- Colours: every colour is an Omarchy theme key (`--accent`, `--bg`, `--fg-dark`... as in the
  spec). The CSS has Tokyo Night (dark) and Lupine (light); picking a theme under the window sets
  the keys inline. The 22 bundled themes sit between the `/* themes */` markers, written by
  `node themes.mjs` from `/usr/share/omarchy/themes` (rerun after an Omarchy update; CI has no
  Omarchy, so the build doesn't).
- `build.mjs`: builds `dist/` (git-ignored): the page wrapped into a whole document (meta,
  canonical, JSON-LD, favicon), robots and sitemap. Reads omaseed's latest release into every
  `<span class="ver">` and its open issues into "What's next" (between `<!-- next -->` markers:
  issues labelled `next`, or with none labelled, the newest open enhancements). Without GitHub it
  keeps what the source has. `node build.mjs` (Node 18+, no dependencies; `GITHUB_TOKEN` optional).
- `site/media/`: the favicon (provenance in `site/media/README.md`).
- `/install` and `/changelog` don't exist yet: they come after the home page is approved.

## Publishing the draft

The draft lives at <https://claude.ai/artifact/H34VpeUTKrAWnqG9ypoqGC> (private; version 5 on
2026-10-13). `site/omaseed.html` in this repo is its source, so the repo holds the draft too. From
a new session, read it first (Artifact `action: "read"` with its `url`), then publish with the same
`url` and `file_path: site/omaseed.html`.

What each replica on the page is drawn from, and the exact words it copies, is in
`reference/SPEC-NOTES-2026-10-13.md`.

## Repository

Private, <https://github.com/diogochaves/omaseed-site> (created 2026-10-13 at Diogo's request).

## Hosting (as omabox.app)

Cloudflare Pages project `omaseed` (account 433e2ce2a5dce0c5eae78569eccd4122), deployed by
`.github/workflows/deploy.yml` with wrangler: on every push to main, daily at 06:27 UTC (a new
omaseed release, its version and the open issues show up) and by hand (`gh workflow run deploy -R
diogochaves/omaseed-site`). The token is the repo secret `CLOUDFLARE_API_TOKEN` (Cloudflare Pages:
Edit on the account; DNS: Edit and Zone: Read on omaseed.app). The repo variable `SITE_URL` is
`https://omaseed.app` (canonical, link card, robots, sitemap; any other value gets noindex). The
workflow's last step keeps omaseed.app and www.omaseed.app attached to the project and their DNS
pointed at it; www only redirects to omaseed.app (301) in `functions/_middleware.js`, and
`dist/_routes.json` keeps `/media/*` out of it. Decided 2026-10-13 (Diogo: "host it on
cloudflare, like omabox.app"). The artifact stays where Diogo reviews drafts; omaseed.app is what
main builds.

## Checking a change

Never open the page on Diogo's real desktop. In a box:

```bash
L=$(mktemp -d); cp -r site/media $L/
{ echo '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover"></head><body>'; cat site/omaseed.html; echo '</body></html>'; } > $L/index.html
omabox up -b look --ro-bind $L
omabox run -b look -d --wait -- chromium --user-data-dir=/tmp/chr --no-first-run --no-default-browser-check --ozone-platform=wayland --app=file://$L/index.html
omabox shot -b look --fit 1456          # Page_Down with: omabox click -b look 1700 300, then omabox keys -b look Page_Down
omabox mode -b look 412x915             # phone width
omabox down -b look; rm -r $L
```
