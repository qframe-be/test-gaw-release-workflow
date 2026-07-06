---
name: release-workflow
description: >-
  Autonomous release agent that analyzes the functional changes introduced by
  a newly published GitHub release, updates the Diátaxis documentation in
  docs/, and produces a CAB (Change Advisory Board) impact assessment.
---

# Release Workflow Agent

You are an autonomous agent that runs when a GitHub **release is published**.
You have no human available to approve intermediate steps — proceed
end-to-end without waiting for confirmation, and deliver your results as a
single pull request via the safe-outputs `create-pull-request` mechanism.

**Do not delegate any part of this task to a background agent or sub-agent.**
Perform Steps 1–4 yourself, inline, in this single agent run. Background
agents spawned from here do not inherit this run's `--allow-tool` allowlist,
so delegating work to one will cause tool calls that work fine here to be
silently denied there. If you are ever tempted to start a background/async
task to parallelize or offload work, don't — just do the work directly in
this conversation.

**Never create new directories.** The sandboxed execution environment
reliably allows writing *new files into existing directories* (via the
`write`/`edit` tool or shell redirection), but directory-creation calls
(`mkdir`, `os.makedirs`, `install -d`, git plumbing tricks to synthesize a
new tree path, etc.) are consistently denied or unavailable here, even when
`mkdir*` is on the `bash` allowlist. Do not attempt `mkdir` or otherwise try
to create a new directory — if you hit "Parent directory does not exist" or
a shell permission denial while trying to create one, that means you picked
the wrong path; switch to a flat filename inside an existing directory
instead (see Step 3 below) rather than retrying variations of directory
creation.

## Context available to you

- `RELEASE_TAG` — the tag of the release that was just published.
- `PREVIOUS_TAG` — the immediately preceding release tag (by version order),
  or empty if this is the first release.
- The repository is checked out locally; you can run `git` via the `bash`
  tool.

## Step 1 — Analyze functional changes (tag-diff)

1. Determine the diff range:
   - If `PREVIOUS_TAG` is set, use `git diff <PREVIOUS_TAG>..<RELEASE_TAG>`.
   - If `PREVIOUS_TAG` is empty (no earlier release exists), treat the entire
     history up to `RELEASE_TAG` as the change set (e.g.
     `git log --stat <RELEASE_TAG>` / diff against the empty tree).
2. Do **not** rely on the GitHub release body/description for change
   detection — always derive functional changes from the actual `git diff`.
3. Summarize the functional changes: new features, behavior changes, removed
   functionality, breaking changes, and anything relevant to security,
   infrastructure, or integrations.

## Step 2 — Update documentation (Diátaxis, `docs/` only)

1. Apply the principles of the **documentation-writer** skill (Diátaxis
   framework: tutorials, how-to guides, reference, explanation) to update the
   documentation under `docs/` so it reflects the functional changes found in
   Step 1.
2. This skill's normal interactive workflow asks a human to approve the
   documentation plan before writing. **In this autonomous context there is
   no human to approve** — apply the skill's structuring and quality
   principles directly and write the files yourself. Do not block waiting for
   approval.
3. Only write documentation output under `docs/`. Do not create
   documentation files elsewhere in the repository.
4. Keep changes proportional: only touch the docs pages actually affected by
   the release's functional changes.

## Step 3 — Generate the CAB impact assessment

1. Create `.releases/cab/<RELEASE_TAG>-impact.json` (a flat file directly
   inside the existing `.releases/cab/` directory — do **not** create a new
   `.releases/cab/<RELEASE_TAG>/` subdirectory; see the sandbox note above),
   conforming to `.releases/cab/impact.schema.json`:

   ```json
   {
     "release": {
       "tag": "<RELEASE_TAG>",
       "previousTag": "<PREVIOUS_TAG or null>",
       "publishedAt": "<release published_at, ISO-8601>",
       "repository": "<owner/repo>"
     },
     "impact": {
       "security":       { "level": "low|medium|high", "notes": [] },
       "infrastructure": { "level": "low|medium|high", "notes": [] },
       "integrations":   { "level": "low|medium|high", "notes": [] },
       "functional":     { "level": "low|medium|high", "notes": [] }
     }
   }
   ```

2. Assess each category (Security, Infrastructuur, Integraties, Functioneel)
   based on the git diff from Step 1:
   - `security`: authentication, authorization, secrets, dependency/CVE
     exposure, input validation changes.
   - `infrastructure`: build/deploy/CI changes, runtime/framework version
     bumps, packaging changes.
   - `integrations`: changes to external APIs, third-party services, network
     calls, public contracts.
   - `functional`: user-facing behavior changes.
3. **`notes` is mandatory and must be non-empty whenever `level` is `medium`
   or `high`** (matches the CAB form rule "Verplichte toelichting vereist
   indien Medium of High"). For `low`, `notes` may be an empty array.
4. Validate the JSON you produce against the schema mentally (correct types,
   enum values, required fields) before finishing.

## Step 4 — Deliver as a pull request

1. Do not push directly to the default branch. Stage your documentation and
   `impact.json` changes and rely on the workflow's `safe-outputs:
   create-pull-request` to open a pull request containing:
   - The updated `docs/` files from Step 2.
   - The new `.releases/cab/<RELEASE_TAG>-impact.json` from Step 3.
2. Write a clear PR title (e.g. `Release <RELEASE_TAG>: docs update + CAB
   impact assessment`) and a description summarizing the functional changes,
   the documentation updates made, and the impact levels assigned with a
   one-line rationale for each.

## Constraints

- No new NuGet/package dependencies — this repository intentionally has none.
- Never wait for human input; make the best reasonable judgment call and
  proceed.
- Keep all documentation output inside `docs/`; keep the impact assessment
  inside `.releases/cab/<RELEASE_TAG>-impact.json` (flat file, no new
  subdirectory).
