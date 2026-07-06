# Reference: CAB Release Impact Assessment

Technical reference for the automated Change Advisory Board (CAB) impact
assessment produced for every published GitHub release.

## Overview

Every time a release is published on GitHub, the `release-workflow` agentic
workflow (`.github/workflows/release-workflow.md`, driven by the custom agent
`.github/agents/release-workflow.agent.md`) runs automatically and:

1. Diffs the new release tag against the previous release tag (`git diff
   <previousTag>..<newTag>`) to determine the **functional changes** —
   the release body/description is not used for change detection.
2. Updates the documentation in `docs/` to reflect those changes.
3. Writes a CAB impact assessment to
   `.releases/cab/<release-tag>-impact.json`.
4. Opens a pull request containing both the documentation updates and the
   `impact.json` file.

If no previous release tag exists (e.g. the first release), the workflow
treats the full history up to the new tag as the change set.

## File location

```
.releases/cab/<release-tag>-impact.json
```

Each release gets its own flat file named after its tag (for example
`.releases/cab/v1.2.0-impact.json`), so historical assessments are never
overwritten. Files are kept flat inside the existing `.releases/cab/`
directory rather than in per-release subdirectories, since the agent's
sandboxed execution environment does not reliably support creating new
directories.

## Schema

The JSON structure is validated against
[`.releases/cab/impact.schema.json`](../.releases/cab/impact.schema.json).

| Field                       | Type              | Required | Description                                                          |
|------------------------------|-------------------|----------|------------------------------------------------------------------------|
| `release.tag`                | string            | yes      | The published release tag (e.g. `v1.2.0`).                            |
| `release.previousTag`        | string \| null    | yes      | The previous release tag used as the diff base, or `null` if none.    |
| `release.publishedAt`        | string (ISO-8601) | yes      | Timestamp of when the release was published.                          |
| `release.repository`         | string            | yes      | The `owner/repo` this release belongs to.                             |
| `impact.security`            | object            | yes      | Impact category — see below.                                          |
| `impact.infrastructure`      | object            | yes      | Impact category — see below.                                          |
| `impact.integrations`        | object            | yes      | Impact category — see below.                                          |
| `impact.functional`          | object            | yes      | Impact category — see below.                                          |

### Impact category object

| Field   | Type            | Required                              | Description                                                        |
|---------|-----------------|----------------------------------------|----------------------------------------------------------------------|
| `level` | `"low"` \| `"medium"` \| `"high"` | yes                  | Severity of impact for this category.                              |
| `notes` | array of string | yes (non-empty when `level` is `medium` or `high`) | Toelichting (explanation) for the assigned level.                  |

The four categories mirror the CAB form:

- **`security`** — Security (authentication, authorization, secrets,
  dependency/CVE exposure, input validation).
- **`infrastructure`** — Infrastructuur (build/deploy/CI changes, runtime or
  framework version bumps, packaging).
- **`integrations`** — Integraties (changes to external APIs, third-party
  services, network calls, public contracts).
- **`functional`** — Functioneel (user-facing behavior changes).

### The mandatory-notes rule

`notes` **must** be a non-empty array whenever the corresponding `level` is
`medium` or `high`. This mirrors the CAB form's rule: *"Verplichte
toelichting vereist indien Medium of High"* (mandatory explanation required
if Medium or High). When `level` is `low`, `notes` may be an empty array.

## Example

See [`.releases/cab/v0.1.0-sample-impact.json`](../.releases/cab/v0.1.0-sample-impact.json)
for a filled-in example:

```json
{
  "release": {
    "tag": "v0.1.0-sample",
    "previousTag": null,
    "publishedAt": "2026-07-02T10:00:00Z",
    "repository": "qframe-be/test-gaw-release-workflow"
  },
  "impact": {
    "security":       { "level": "low",    "notes": [] },
    "infrastructure": { "level": "low",    "notes": [] },
    "integrations":   { "level": "low",    "notes": [] },
    "functional":     { "level": "medium", "notes": ["..."] }
  }
}
```

## Related files

- `.github/workflows/release-workflow.md` — the gh-aw workflow definition
  (trigger, tools, safe-outputs).
- `.github/agents/release-workflow.agent.md` — the custom agent's detailed,
  autonomous instructions for change analysis, documentation updates, and
  impact scoring.
- `.releases/cab/impact.schema.json` — the JSON Schema enforced above.
