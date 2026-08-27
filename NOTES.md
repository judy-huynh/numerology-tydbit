# Tidbyt Notes

Working notes for this repo and for the household Tidbyt apps we want to build next.

---

## How this actually runs

The daily update comes from **GitHub Actions, not from the Mac.** `.github/workflows/main.yml`
runs at `1 5 * * *` (05:01 UTC = 01:01 ET), renders `numerology.star` with pixlet, and pushes
the webp to the device. The app defaults to `America/New_York`, so a 01:01 ET run gets the right
date.

The Tidbyt keeps showing the last pushed image forever. Nothing on the device recalculates.
No push means yesterday's number stays up.

### Trigger it by hand

```bash
gh auth switch -u judy-huynh          # gh defaults to the rebuildbydesign account
gh workflow run "Daily Numerology Refresh" --ref main
gh run watch <run-id> --exit-status
gh auth switch -u rebuildbydesign     # switch back
```

---

## Known issues

**GitHub drops scheduled crons.** 27 Aug 2026 the clock was stuck on yesterday's 8/8. The Action
had run on time every day from 15 to 26 Aug, then GitHub silently skipped the 05:01 UTC trigger.
Nothing was broken. Fixed with a manual `workflow_dispatch`. If this keeps happening, add a second
cron line an hour later so a dropped trigger self-heals.

**Dead launchd job.** `~/Library/LaunchAgents/com.numerology.tidbyt.plist` still exists and still
fails with exit 127. It points at `~/Downloads/Numerology Tidbyt`, a path that no longer exists
since the folder moved into `2026-JUDY PROJECTS/`. Harmless, but it is not a backup either.
Either delete it or repoint it at `Numerology Tidbyt/refresh.sh` so the Mac catches days the
Action drops.

**Token in plaintext.** `Numerology Tidbyt/refresh.sh` has the live Tidbyt API token and device ID
hardcoded. Only `.DS_Store` is gitignored, so that file is one `git add` away from being public.
Worth rotating.

**Two copies of the app.** `numerology.star` exists at repo root and inside `Numerology Tidbyt/`.
The Action renders the root one. The subfolder is the old local-cron setup.

---

## Constraints to design around

- 64x32 pixels. Roughly 4 to 6 readable characters per line with the small font, fewer if bold.
- Animation works (`render.Animation`, multi-frame webp), so pacing and motion are on the table.
- No interactivity. No buttons, no touch. The app just appears in the rotation.
- Anything that should change during the day needs more frequent Action runs, not device logic.
- Config comes from the schema dropdowns in the Tidbyt mobile app.
- Content that changes without a code edit should live outside the repo. A Google Sheet published
  as CSV plus `http.get` at render time is the easy pattern, and it means the household can add to
  it without touching code.

---

## Ideas backlog: household mindset apps

Goal is mindset, positivity, strength, courage, confidence, for the whole house and not just the
desk. Nothing here has copy written yet. **Copy is Judy's, not generated.** These are mechanisms.

### 1. Real words from real people
Shows one real thing an actual person said about someone in the house. Sourced from texts, emails,
reviews, cards, performance feedback. Rotates daily or per app cycle.
Why it lands: confidence built from evidence, not affirmations. Nothing to disbelieve.
Build: a Sheet with `quote`, `who`, `about`, pick one per day, attribute in small text.
**Recommended first build.** Easiest to ship, hardest to dismiss on a bad day.

### 2. Box breathing pacer
An animated square or ring that walks 4-4-4-4. In, hold, out, hold. Runs as long as the app is on
screen.
Why it lands: the only one that does something in the moment rather than saying something.
Build: `render.Animation` frames, no external data. Pure code, no content decisions.

### 3. Streak counter
Days of a thing. Shipped, moved, showed up, stayed off something. Big number, small label.
Why it lands: courage compounds when it is visibly counted.
Build: a start date in config or a Sheet, count from it. Trivial. The hard part is choosing the
one streak worth watching.

### 4. Household wins board
Anyone in the house adds a win to a shared Sheet from their phone. Display surfaces one at random.
Why it lands: makes the household a witness, not just an audience.
Build: same CSV pattern as #1. Add a date so recent wins can be weighted.

### 5. Countdown with momentum
Days until a real milestone, paired with a count of what has already been done toward it.
Not "47 days left" alone, which reads as pressure. "47 left / 12 done" reads as movement.
Build: two numbers, one from config, one from a Sheet.

### 6. Daily word
One word, filling the whole screen. Curated list, no explanation.
Why it lands: it is the most visible thing on the device and it costs nothing to read.
Build: simplest possible. The whole project is the word list, which is a Judy problem, not a code
problem.

### 7. Light and season
Sunrise, sunset, daylight remaining, moon phase. No message at all.
Why it lands: grounding without instruction. Good counterweight to the apps that talk.
Build: sunrise/sunset math from lat/long, or a free API at render time.

### Cross-reference
Overlaps with the **Manifest Station** project (one-button positivity machine, departures-board
direction, 7 chakra lines x 9 numerology platforms). If Manifest Station gets a data model for
positivity content, the Tidbyt apps should read from the same source rather than build a second one.

---

## Decisions still open

- Which app to build second, after the first ships.
- Whether these become separate repos or one repo with multiple `.star` files and one Action that
  pushes to different installation IDs. One repo is less overhead. Separate repos read better on
  the GitHub profile.
- Where the shared content lives. Google Sheet is the low-friction answer if the household is going
  to contribute.
