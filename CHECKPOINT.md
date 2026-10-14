# Checkpoint (2026-10-14)

Where the work stopped and what comes next. Replace this file as the work moves on.

## Done
- Repo created, local only: no GitHub remote, nothing pushed or published.
- `DIRECTION.md` written with the references, the page order and what is not claimed yet.
- Research done (see `reference/RESEARCH-2026-10-14.md`): Raycast, Linear and herdr.dev read top to
  bottom; the design-skill ecosystem surveyed from X replies.

## Next (in this order)
1. Ask Diogo the four open questions at the end of `DIRECTION.md` (promise line, one page or
   several, roadmap yes/no, how prominent the omabox credit is). Defaults are written there; he
   may just say "defaults".
2. Copy the build and base styles from `~/code/omarchy/omabox-site` (`build.mjs`, `site/base.css`,
   the artifact-source layout in its AGENTS.md) and adapt. Each Omarchy theme gives the accent.
3. Draft the home page with the playable mock (library table with labelled demo data, click a
   torrent for details, `` ` `` flips to the seed console, theme switch). Look from
   `~/code/omarchy/omaseed/docs/05-ui-spec-v2.html` (read only) and `omaseed/docs/screenshots/`.
   Publish as a **private** artifact for Diogo to review.
4. Measure memory and CPU (omaseed on the :8081 playground in an omabox; never :8080), then put the
   numbers and the method on the page. Until then the page makes no such claim.
5. Only after the home page is approved: `/install`, `/changelog` (read from the omaseed repo's
   latest tag, like omabox-site), then the other pages.

## Standing rules
- Nothing published, pushed or put on a domain until Diogo asks. Creating a GitHub repo for this is
  his call.
- Windows, screenshots, running omaseed: through omabox (load the omabox skill).
- omaseed's design is approved and its spec files are never edited. The site shows it, it does not
  redesign it.
