# Checkpoint (2026-10-13)

Where the work stopped and what comes next. Replace this file as the work moves on.

## Done
- The four open questions answered (DIRECTION.md, "Decided"): promise line "Torrents, finally at
  home on Omarchy.", home plus /install and /changelog, "What's next" from issues, omabox credit
  as its own section.
- Home page draft 1 (`site/omaseed.html`), published privately:
  <https://claude.ai/artifact/H34VpeUTKrAWnqG9ypoqGC>. A working copy of the main window with
  demo data (click, j k, space, p, `, [ ], 1-4, /, ?), live speeds, the seed console in the window
  and big in its own section, the page repainted by any of the 22 bundled Omarchy themes.
- `build.mjs` (version and "What's next" from GitHub), `themes.mjs`, favicon. Checked in an
  omabox box at 1920x1080 and 412x915.

- Draft 2 (same URL, version 3), from Diogo's notes on draft 1: the window has a "Try" row and
  pulsing pointers; the right-click and `enter` actions menu as shipped (ActionsMenu.qml order); the
  add sheet (`a` or +) with "In Downloads", the files-on-disk match, the duplicate sheet, the file
  tree and free-space line; delete with the last-seed guard; drop a real .torrent on the window and
  it's read in the page (bdecode, never sent anywhere). New sections "Adding torrents" and "Careful
  with your data"; Servers and Omarchy got replicas (settings › Servers, the certificate prompt, the
  bar widget and popup, playable; notifications; the shortcuts sheet with a working filter). Copy
  and looks from the spec agents' reports on docs 05, 14, 17, 18, 19, 25, 26, 28 and the QML.
  "Why it errored" is labelled "next release" (unreleased on main).

- Version 4 (same URL): omaseed v0.2.0 (13 Oct 2026) ships a prebuilt package. The hero and
  Install show its one line (`curl -fLO …/latest/download/omaseed-x86_64.pkg.tar.zst && sudo
  pacman -U …`, as in omaseed's README), building from source folded under it. The changelog's
  "Next" entry became v0.2.0; "Why it errored" says "new in 0.2.0" (its key hints were broken by
  the window's `.acts` rules, now `.eacts`). The omabox section has omabox's mark and "No desktops
  were harmed in the making of omaseed. And no mouse was captured." New "Open source" section
  (MIT, code, issues, pull requests); omaseed has no CONTRIBUTING.md, so none is linked.
- The hero's "NEW" pill text (`v0.2.0: errors explained, one-line install`) is hand-written: the
  build updates only the version number in it, so change the words at each release.

- Live at <https://omaseed.app> since 2026-10-13 (Cloudflare Pages project `omaseed`, first deploy
  run 38502344180); www.omaseed.app redirects to it. The deploy token is omabox-site's, extended
  to omaseed.app and rolled the same day; both repos hold the new value.

## Next (in this order)
1. Diogo reviews the live page (and the artifact, version 5). Open with him: label `next` on omaseed issues to choose "What's next"
   (today it shows the newest four enhancements). Known glitch: opening the page at a `#section`
   address lands past that section (in-page nav clicks are fine).
2. Measure memory and CPU (omaseed on the :8081 playground in an omabox; never :8080), then put the
   numbers and the method on the page. Until then the page makes no such claim.
3. After the home page is approved: `/install`, `/changelog` (read from the omaseed repo's latest
   tag, like omabox-site), and a link card image (the head has no og:image yet).

## Standing rules
- The repo is private on GitHub (diogochaves/omaseed-site); pushing to main deploys omaseed.app
  (Cloudflare Pages, as omabox.app; AGENTS.md, "Hosting"). Push only what Diogo has seen.
- Windows, screenshots, running omaseed: through omabox (load the omabox skill).
- omaseed's design is approved and its spec files are never edited. The site shows it, it does not
  redesign it.
