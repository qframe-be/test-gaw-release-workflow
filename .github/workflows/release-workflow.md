---
description: >-
  When a release is published, analyzes the functional changes since the
  previous release, updates docs/ with the documentation-writer skill, and
  produces a CAB impact assessment JSON — delivered as a pull request.

# Trigger - run whenever a release is published
on:
  release:
    types: [published]

# Read-only permissions for the agentic portion of the run.
# Write access (opening the PR) is handled by the safe-outputs job.
permissions:
  contents: read
  copilot-requests: write

# AI engine: Copilot, driven by the custom release-workflow agent file
# (.github/agents/release-workflow.agent.md)
engine:
  id: copilot
  agent: release-workflow
  env:
    COPILOT_GITHUB_TOKEN: ${{ secrets.COPILOT_GITHUB_TOKEN }}

# Tools available to the agent
tools:
  github:
    toolsets: [repos]
  edit:
  bash:
    - "git log*"
    - "git diff*"
    - "git tag*"
    - "git describe*"
    - "git show*"
    - "mkdir*"

# Network access
network: defaults

# Deliver everything as a single pull request
safe-outputs:
  create-pull-request:
    title-prefix: "[release-workflow] "
    labels: [release, documentation, cab]
---

# Release Workflow

Compute the diff range for this release and hand it to the
`release-workflow` custom agent (see
`.github/agents/release-workflow.agent.md` for the full autonomous
instructions).

## Context

- Triggering release tag: `${{ github.event.release.tag_name }}`
- Repository: `${{ github.repository }}`
- Release publish time: look this up yourself via the GitHub `repos` tool
  (get release by tag) rather than relying on a template expression.

## Instructions

1. Determine the previous release tag:
   - List tags reachable in history before `${{ github.event.release.tag_name }}`,
     ordered by version, e.g.:
     ```bash
     git tag --sort=-v:refname
     git describe --tags --abbrev=0 "${{ github.event.release.tag_name }}"^ 2>/dev/null || true
     ```
   - If no previous tag exists, treat this as the initial release (no
     previous tag).
2. Run `git diff <previousTag>..${{ github.event.release.tag_name }}` (or the
   full history if there is no previous tag) to identify the **functional
   changes** introduced by this release. Do not use the release body/notes as
   the source of truth for change detection.
3. Update the documentation under `docs/` to reflect those functional
   changes, applying the documentation-writer skill's Diátaxis principles
   autonomously (no human approval step — this is a CI run).
4. Generate `.releases/cab/${{ github.event.release.tag_name }}/impact.json`,
   conforming to `.releases/cab/impact.schema.json`, assessing Security,
   Infrastructuur, Integraties, and Functioneel impact (`low`/`medium`/`high`)
   with mandatory non-empty `notes` whenever a category is `medium` or
   `high`.
5. Open a pull request containing the documentation updates and the new
   `impact.json`, with a description summarizing the functional changes and
   the rationale behind each impact level.

## Notes

- Run `gh aw compile` after editing this file to regenerate
  `release-workflow.lock.yml`.
- See https://github.github.com/gh-aw/ for complete configuration options.
