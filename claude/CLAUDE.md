# CLAUDE.md — personal layer

User-level instructions that apply across every project. Loaded automatically by Claude Code in every session, in addition to any project-level `CLAUDE.md`.

Project-level files override or specialise this layer (e.g. they supply the test commands, branch names, base branch, reviewer handles, Jira instance, PR body URL — everything stack- or team-specific). Read both as a single set of rules.

---

## Claude Code Rules

- **Never mention Claude** in commit messages, PR descriptions, code comments, or authorship — all contributions are attributed to the developer
- **Always use modern JavaScript/TypeScript features** (or the equivalent in the project's language) — optional chaining, nullish coalescing, destructuring, `const`/`let`, async/await, etc.
- **Always follow clean code principles** — meaningful names, single responsibility, small focused functions, no magic numbers/strings
- **Always avoid antipatterns and code smells** — no callback hell, no deeply nested conditionals, no god objects, no premature optimization, no mutating shared state directly; no non-null assertions, unsafe type casts, dead code, magic values, inappropriate intimacy, speculative generality, or duplicated logic
- **Always consider extraction and refactoring** — if logic is reusable or a function grows complex, extract it; prefer composition over duplication
- **Always use descriptive variable names** — no shortened or abbreviated names (e.g. `userAvatar` not `ua`, `isAuthenticated` not `isAuth`, `claims` not `c`)
- **Always separate code blocks with a blank line** — treat blank lines as visual punctuation, grouping related lines into logical "paragraphs" (ref: _Clean Code_, Robert C. Martin, Ch. 5 — Vertical Openness Between Concepts). Each paragraph represents one conceptual step; blank lines mark transitions between them. Exception: consecutive one-line conditionals or loops (e.g. guard clauses) form a single concept and stay grouped; only block-body conditionals/loops (`{}`) require blank lines between them and surrounding code
- **Always use `--force-with-lease` instead of `--force`** when force pushing — never use bare `--force`
- **Always update `.gitignore` when introducing a new file that should not be committed** — generated files, env files, coverage output, tool config files (e.g. `CLAUDE.md`). Do this in the same commit that introduces the file, or in an immediately preceding one

---

## Task Workflow

Project CLAUDE.md supplies the project-specific instantiations: base branch name, branch-naming pattern, ticket-tracking system + transitions, test/lint/type-check commands, PR-body URL pattern, reviewer handles, merge-permission specifics. Everything below is the cross-project discipline.

### Mandatory pre-action surface for high-cost actions

The four high-cost actions below are **never** taken without first surfacing the protocol state and waiting for explicit consent. This is structural — the documented protocol is consulted *before* the action, not recalled afterwards as a checklist of what was skipped.

| Action | Surface format before taking it |
|---|---|
| `git push` (any branch, any kind) | "Pushing `<branch>` to remote. Checklist for the action: [what's walked / what isn't / blockers]. Ready?" |
| `gh pr create` (draft or ready) | "Opening PR `<base>...HEAD` as `<draft\|ready>`. Checklist: gates / body verify / forbidden-ref grep / recipe walk / refactor assessment. Ready?" |
| `gh pr ready` | "Marking PR #N ready. Checklist: CI green on head SHA / Sonar inline annotations triaged / mergeable=MERGEABLE / verification workflow SHIP verdict. Ready?" |
| `gh pr merge` | "Merging PR #N (`<strategy>` + `<admin>` + `<delete-branch>`). Checklist: reviewDecision=APPROVED or no required reviewers / no open review comments needing reply / mergeable / CI green. Ready?" |

**Why this exists.** Each of these actions is publicly observable (CI fires, notifications go out, branches become discoverable, code lands on `develop`). The protocol's whole point is to front-load 30 seconds of verification so it prevents 5–30 minutes of recovery if a missed step surfaces downstream. Skipping the surface saves the cheap cost and incurs the expensive one. The rule is mechanical: surface first, every time, until the user explicitly opts out of the surface for a defined window.

This is a default, not a per-ticket reminder — the user should not have to ask "did you follow protocol?" or "are you about to push?" for it to fire.

### Starting a task

1. Branch from the project's base branch (project file names it — often `master`, `develop`, or `main`) using the project's branch-naming pattern.
2. Transition the ticket → `In Progress` in the project's tracking system.
3. **Verify the ticket is in the active sprint/iteration.** Backlog tickets must be moved into the active sprint before work begins — otherwise the card won't appear on the sprint board, the work won't count for sprint analytics, and reviewers struggle to find it.

### Pre-implementation discipline (do BEFORE the first feature edit)

Steps that get silently skipped when the work feels "small enough." Each is a real recovery from a real miss — when in doubt, document the step's output so you can prove to yourself you didn't skip it.

- **Refactor-first audit, documented inline.** Scan the files the ticket will touch; list each candidate as Bundle / Defer with a one-line Why. Honour the 3rd-instance extraction threshold. The audit is a deliverable, not a mental exercise — paste it into the PR body under a `## Refactor assessment` section. Doing it in your head and skipping the write-up is the actual failure mode.
- **Verify the dev-notes / spec against current state.** Predictive planning docs drift between writing and execution. Re-check every "Depends on" / "What's already in place" / "File-by-file impact" claim against the live branch before trusting them. Note any drift in the PR body so the reviewer doesn't trip over the same gap.
- **Verify the ticket-system state.** Issue type can change transition validity (e.g. Story vs Task on some boards). If the ticket is in backlog, confirm whether the PO wants it moved into the active sprint before you transition status — sprint membership is generally the PO's call, not the implementer's. When uncertain, leave the ticket untouched and surface the decision at PR-open time.

### During development

- Implement and commit freely using the project's `wip:` (or equivalent) prefix — history quality does not matter yet
- Follow static-analysis-safe practices throughout: no code smells, no security hotspots, no duplication, coverage at or above the project's threshold on new/changed code
- For UI work: at least one **manual browser smoke check** before invoking the code review step. Catches visual glitches, console errors, and routing edge cases automated tests miss

### When implementation is complete — code review

Delegate to a sub-agent (Explore or general-purpose) for independent review. Brief it with the branch name and ask it to audit the full diff against the base branch:

1. Read the full diff (`git diff <base>...HEAD`)
2. Audit for:
   - CLAUDE.md convention adherence (naming, blank-line discipline, semicolons / language idioms, modern features, no Claude attribution)
   - Clean code violations — magic values, deep nesting, oversized functions, unclear names, missing single-responsibility
   - Antipatterns — callback hell, god objects, mutating shared state, premature optimization, deeply nested conditionals
   - Code smells — long method, large class, long parameter list, primitive obsession, feature envy, data clumps, message chains, inappropriate intimacy, speculative generality, dead code, duplicated logic, comments explaining bad code, non-null assertions, unsafe type casts
   - Refactoring & extraction opportunities — repeated logic to extract, complex blocks to break into named helpers, prop drilling to lift into a shared abstraction, inline magic to promote to named constants, components/modules growing past single responsibility to split
   - Security — boundary validation, no secrets, no injection vectors
   - Test coverage gaps on new/changed lines (at or above project threshold)
   - Static-analysis red flags — high cognitive complexity, duplicated blocks, security hotspots
3. Address every finding. Re-delegate after fixes for a follow-up pass.
4. **Cap at 2 review passes.** If the second pass still surfaces non-trivial findings, list the unaddressed items in the PR body under a "Deferred review notes" section so the human reviewer knows they were considered and explicitly deferred — don't loop indefinitely on nits.
5. Only proceed to pre-reset checks once review is clean (or capped + documented).

### Pre-reset checks — full gate

This is the *real* gate. Catch issues here, before the history rewrite, while the wip state is still recoverable.

Run, in order: unit tests, E2E tests, linter, type checker, **production build**, manual browser smoke (UI work only — already done during dev, re-run if the diff has changed since). The exact commands are in project CLAUDE.md. Fix any failures before proceeding.

**Why the production build is non-negotiable:** project type-checkers (e.g. `vue-tsc --noEmit`) operate in isolation-mode and miss errors that the Rollup-based production build catches — most commonly around template-expression type narrowing and prop-handler signature mismatches (e.g. forwarding `refetch` directly to `@click` when it expects `(payload: PointerEvent) => void`). The full build pass catches these *before* CI does. Adopted after a real miss when a clean `tsc` masked a TS error that only `vite build` surfaced.

### Clean up git history

1. Soft reset all branch commits: `git reset $(git merge-base HEAD <base>)`
2. Review all unstaged changes and recommit in logical, clean groups
3. Open **draft PR** assigned to yourself — **do not request reviewers yet** (reviewers are added when marking ready for review):
   - **Title:** `{TICKET-ID}: {ticket summary}` — keep under 70 characters; details belong in the body
   - **Body template:**

     ```
     ## Description
     {what this PR does}

     ## {Ticket-system}
     [{TICKET-ID}]({ticket-url}) — {ticket summary}

     ## Changes
     {explanation of what changed and why}

     ## Testing
     {step-by-step browser testing instructions — always include for any UI change that can be viewed in the browser:
     checkout, install, dev-server, then specific steps to verify the feature}

     ## Acceptance Criteria
     {checklist pulled from the ticket description}
     ```

4. Force push with `git push --force-with-lease`

### Before marking PR ready for review — post-reset checks

A soft reset + recommit doesn't change the working tree, so this is a lightweight sanity pass — not a re-run of the full gate.

1. Lint — sanity check (catches accidental file corruption during git surgery)
2. Type check — sanity check
3. **Rebase onto the target branch.** PRs sit ~hours-to-days on average; the target may have moved. `git fetch && git rebase origin/<target> && git push --force-with-lease` — catches base drift before the reviewer sees it
4. Verify coverage meets the project's threshold on new/changed code
5. Review new code for static-analysis red flags — security hotspots, duplication, complexity
6. **CI must be green on the current head SHA before mark-ready — non-negotiable.** Run `gh pr checks <N>` and confirm a check exists AND all checks are `SUCCESS`. If no checks were reported, CI didn't fire — common causes: PR target isn't in the workflow's `pull_request: branches:` filter (retarget to a CI-triggering branch first), or the `pull_request` types filter doesn't include `ready_for_review`/`edited` (push an empty wip commit — `git commit --allow-empty -m "wip: trigger CI"` — to fire `synchronize`; the wip will be absorbed by the squash merge). Wait for green before flipping ready. **Same rule applies after pushing to address `CHANGES_REQUESTED` — verify CI green on the new head before re-requesting review.** CI verification cannot be shifted onto the reviewer.
7. **Verify `mergeable: MERGEABLE` via `gh pr view`.** Resolve conflicts and re-push first if not.
8. Fix any issues.
9. **Verify the documentation of both the PR and the repo as if you were the reviewer.** Read every line cold.

   **PR body** — every claim in Description, Changes, Refactor assessment, Testing, and Acceptance Criteria must trace to actual code or fixtures in this PR's diff. If a bullet says "X happens" or "Y is hoisted to Z", verify the file/line exists. Specific checks for the Testing section:
   - Checkout / setup commands work on a fresh clone (`gh pr checkout <N> -f` to force refresh of any stale local ref; restore any gitignored env file the setup needs).
   - State-change instructions account for runtime caveats — some build systems (e.g. Vite) do NOT hot-reload env vars; explicitly say "restart the dev server" wherever the recipe asks the reviewer to change an env value.
   - Hard-reload step is explicit (`Cmd+Shift+R` / `Ctrl+Shift+R`) where the page needs a fresh render.
   - Console-check items are concrete: separate browser console (no framework warnings, no module-resolution errors, no 404s on assets) from terminal console (no build-tool warnings).
   - **Expected values match the actual fixtures or source-of-truth data.** When the recipe asserts a specific value, trace it back to the fixture, i18n key, or default it derives from. Don't copy values from another ticket, don't paraphrase, don't guess from memory. Open the source file and copy verbatim.
   - **Mock-mode-only assertions:** if the app defaults to mock data, never assert behaviour requiring a real backend (network requests, BE state mutation, real BE response shapes) — those belong in service specs, not browser smoke. Add an explicit note where mock-layer limitations affect the expected outcome.
   - Any known traps from previous review cycles are listed under a "Troubleshooting" subsection (build-cache invalidation, common Vite/Webpack/etc gotchas).

   **Repo documentation must reflect current state.** Covers repo-level docs only (`CONTRIBUTING.md`, `README.md`, `.github/*` templates, root-level `*.md`) — team-public artefacts a reviewer or future contributor reads. Personal tracking docs are out of scope here.

   The verification is targeted, not exhaustive: focus on what the PR *introduces* or *materially changes*. New test-utils helper → CONTRIBUTING test-utils section gets an entry. New env var → `.env.example` adds it. "Next candidate" mentioned in CONTRIBUTING and shipped in this PR → doc updates accordingly. README example that references behaviour the PR changed → README updates.

   Common drifts to check: a convention or pattern in `CONTRIBUTING.md` references a file/helper the PR renamed/moved/deleted, or names a "next candidate" the PR shipped; a `README.md` example references behaviour the PR changed; a doc-cited count has shifted; a new env var landed in code but not in `.env.example`.

   The reviewer's first action is to follow the recipe and skim repo docs the PR touches; if either falls apart, the review cycle stalls and you've shipped friction onto the reviewer.
10. **End-to-end recipe walk — actually execute the Testing-section steps and verify each expected result against rendered behaviour.** Step 9 is the static read-the-body pass; this step is the dynamic walk. Static verification catches stale strings, dead refs, and broken `cp` filenames, but it cannot catch behavioural claims that simply don't hold — UI text that doesn't render, click handlers that silently no-op, framework wrappers where an attribute lands on the wrong DOM element, mock-mode caveats that invalidate the recipe.

    Procedure for UI changes:
    - Start the dev server fresh (kill any pre-existing 5173 process to avoid `reuseExistingServer` pollution).
    - Drive each Testing-section step via a one-off Playwright script (e.g. `scripts/smoke-pr<N>-recipe.ts`) using the project's auth + mock-state fixtures. For each step, snapshot the assertion target (visible text, DOM attribute, `document.activeElement`, computed style, console events) and compare against the body's stated expectation. Print the comparison line-by-line so any drift is obvious.
    - For steps the script cannot drive (DevTools panes, screen-reader announcements, actual click-to-focus delegation through a portal-rendered widget), do a manual browser smoke and verify by hand.
    - When a step claims a specific date range / numeric input / interaction sequence, verify it's actually **reviewer-feasible**: a recipe that asks the reviewer to navigate 40 calendar months or type into a portal-rendered widget is a recipe smell, even if the underlying behaviour is correct. Replace with a reachable equivalent that yields the same render-branch.
    - If the script surfaces a real implementation bug (not just a body issue), fix the bug, fold via `--fixup` + autosquash, then re-run the walk. Body claims that match correct behaviour are worth more than body claims that match the current (potentially broken) implementation.
    - Clean up the script before push (drop or `.gitignore`); it's verification scaffolding, not committed code.

    Procedure for pure-tooling / non-UI changes:
    - Static body verification (step 9) is usually sufficient. If the Testing section names a command, run it and verify the output matches what the body claims.

    Why this step exists: a series of recent PRs each had body claims that passed step 9's read-the-body pass but failed step 10's walk-the-recipe pass — an unreachable date range, a fictional DevTools-network-throttling-slows-the-skeleton claim, and a PrimeVue DatePicker where `<label for="X">` paired in DOM but native focus delegation silently didn't fire because the id landed on the wrapper `<span>` instead of the inner `<input>`. None of these would be caught by green CI, green unit tests, or step 9's static read.
11. Mark PR as **ready for review** and request the project's default reviewer (project CLAUDE.md names them).
12. Transition ticket → `Code Review`.
13. **Reassign the ticket to the reviewer** — ticket-system ownership tracks who has the next action; while in Code Review the ticket belongs to the reviewer, not the implementer.

### When the PR is approved (next action: merge)

The ticket stays in `Code Review` until the merge happens.

1. **Verify the merge gates one more time:** `gh pr view <N>` shows `reviewDecision: APPROVED` and `mergeable: MERGEABLE`; `gh pr checks <N>` shows green CI on the current head SHA. If any of those is off, fix it before merging.
2. **Squash-merge:** `gh pr merge <N> --squash --admin --delete-branch` (omit `--admin` if you don't have bypass permission — see project CLAUDE.md). Squash is the team's merge strategy; `--delete-branch` cleans up the remote. **EXCEPTION — stacked PRs:** omit `--delete-branch` if any child PR has its base pointing at this branch (see "Stacked-PR merge recipe" below).

#### Stacked-PR merge recipe

When a child PR is stacked on top of the one being merged (its `base` points at the parent's branch), using `--delete-branch` triggers a GitHub gotcha: the moment the parent branch is deleted, the child PR is auto-closed, and GitHub refuses to reopen or retarget a closed PR whose base no longer exists. Workaround = recreate the child PR fresh against the target branch, losing history.

**Correct order: rebase → retarget → delete.** Keep the parent branch alive until every child is retargeted, then prune the parent.

```sh
# 1. Verify gates on the bottom PR
gh pr view <N> --json reviewDecision,mergeable
gh pr checks <N>

# 2. Merge WITHOUT --delete-branch (the parent branch stays alive)
gh pr merge <N> --squash --admin

# 3. Pull the target branch locally
git fetch origin <target> && git checkout <target> && git pull

# 4. For each stacked child PR (in stack order, parent → child):
PARENT_SHA=$(git rev-parse origin/<parent-branch>)
git checkout <child-branch>
git rebase --onto <target> "$PARENT_SHA"   # replay only this PR's commits onto target
git push --force-with-lease
gh pr edit <CHILD_PR_N> --base <target>    # base flip — allowed: PR is OPEN, parent branch still exists

# 5. After all children are retargeted, delete the parent branch
git push origin --delete <parent-branch>
```

The rebase + retarget happens while the parent branch is still alive, so GitHub allows the metadata flip. Once retargeted, the parent branch is orphaned and can be deleted without consequence.

**Why this matters:** preserves PR history (body, comments, draft state, requested reviewers, ticket reassignments). The "recreate" path loses all of that and creates ticket-system / chat-channel confusion.

### After merge

1. **Local cleanup:** `git checkout <target> && git pull origin <target>`. The local task branch is auto-removed by `gh pr merge --delete-branch`; if it lingers anywhere, prune with `git branch -D <branch>`.
2. Transition ticket → `Done`. Skip any "To Release" interim state unless the team's workflow actually uses it.
3. **Reassign the ticket back to the implementer.** Done has no next-action owner, so the assignee shifts purpose: it now marks who shipped the work for sprint analytics, velocity reports, and the implementer's filtered board view. Without this step, the implementer's sprint board reads near-empty after a productive day because every Done ticket is still assigned to the reviewer or the merger.

---

## Task Estimation

Estimation documents are produced before tickets exist in the tracking system and handed off to the PO for ticket creation. The implementer does **not** create the tickets — that is the PO's responsibility.

### Format conventions

- Each task entry includes: **Type, Points, Priority, Stream, Depends on, Blocks, Description, Acceptance criteria**
- **Stream** and **Parent epic** are defined in project CLAUDE.md
- Ticket IDs use placeholder names (e.g. `PROJ-INFRA-3`, `PROJ-PWA-1`) — the PO assigns real keys when creating in the tracking system
- External blockers (API contracts, design deliverables, team syncs) are listed in an "Open blockers" table at the top and flagged inline with ⚠️ on affected tasks

### Story point scale

| Points | Meaning |
|--------|---------|
| 1 | Trivial — no logic, pure markup or config |
| 2 | Simple component, static or single prop-driven |
| 3 | Component with API integration or non-trivial state |
| 5 | Component with multiple states, conditional logic, or cross-cutting concerns |
| 8 | Architectural task or significant cross-cutting complexity |
