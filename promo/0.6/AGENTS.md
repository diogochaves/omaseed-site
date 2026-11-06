# omaseed 0.6: 0.6 video

A HyperFrames video made with director (`~/code/omarchy/director`). Load the `director` skill
before changing anything here: it has the workflow, the house rules and HyperFrames' own guides at
the version this project pins (`package.json`, `director.hyperframes`).

- `BRIEF.md` the intent, `STORYBOARD.md` the plan, `frame.md` the design: change them first, then
  `index.html`.
- `take.sh NAME` records footage in an omabox box into `assets/footage/`; never the real desktop.
- `director check` after every edit (lint, layout, motion, contrast), `director render` to render
  into `renders/` (`--draft`, `--4k`). Never `hyperframes publish` or `cloud`.
