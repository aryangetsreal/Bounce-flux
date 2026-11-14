# Two MacBook workflow

MacBook Pro M5: integration authority; Godot editor/GUI; Codex CLI; `main` and `feature/core`; merging; export; itch.io. Only this device pushes `main`.
MacBook Air M5: Gemini CLI; isolated `feature/gameplay`; assets and audio research/creation; Claude web UI/review; maintains separate clone. Do not put two agents in the same working directory.

## Clone and Git configuration
On Pro:
`git clone https://github.com/aryangetsreal/Bounce-flux.git`
`cd Bounce-flux`
`git remote -v`
`git switch -c feature/core`
`codex`
On Air:
`git clone https://github.com/aryangetsreal/Bounce-flux.git`
`cd Bounce-flux`
`git switch -c feature/gameplay`
`gemini`
For contributors without push access, have owner add them under repo Settings > Collaborators, or use fork/PR. Having access to several LLM accounts does NOT grant GitHub permissions. If user already created initial docs on Pro, push them to main and pull on Air before branch creation.
`upstream` if needed is `https://github.com/mayureshsonawane17/Bounce-flux.git`; NEVER push to upstream. Avoid `git pull` during unrelated uncommitted changes. Human coordinator approves PR/merge.

## Phase timeline
0–15 min: get tool auth and Godot version, root project, shared docs in repo, branch permissions, web export template checks.
15–60 min: Pro player + rewinding + playable scene. Air isolated guard/trap/evidence. Claude produces standalone HUD in parallel.
60–120 min: Pro integrates components, builds stages 1–2 and prepares a reusable level template, manual smoke test. Air art/audio sources and QA.
120–180 min: Pro builds compact stages 3–5 by reusing mechanics and the level template, then ending; Air polish assets/QA; no new mechanics. If integration fails, cut content.
180–240 min: stop features, test, fix blockers, web export, ZIP and upload itch.io, test deployed URL, push `main`.

## Repeatable verification
`git status --short`
`git log -1 --oneline`
`/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit` (adjust path; on Homebrew use `godot`)
`/Applications/Godot.app/Contents/MacOS/Godot --path .` (human plays; optionally open in Godot editor)
Check console for errors; native run plus browser build required.

## Integration process
Air pushes branch after commit: `git push -u origin feature/gameplay`. Pro runs `git fetch origin`, reviews `git diff feature/core..origin/feature/gameplay -- scripts/guard.gd scripts/trap.gd scripts/evidence.gd scenes/guard.tscn scenes/trap.tscn scenes/evidence.tscn`, then cherry-picks focused commit(s) or merges after ensuring no contested files. Commit integration before next change. For web export, configure Compatibility renderer and single-threaded template, export `index.html`, ZIP web output, upload as itch.io HTML game. See current Godot docs; do not assume manual copy of .godot cache into repository.
