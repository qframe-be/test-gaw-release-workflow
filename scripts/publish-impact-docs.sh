#!/usr/bin/env bash
#
# scripts/publish-impact-docs.sh <impact-json-path> <release-tag>
#
# Publishes a CAB release impact assessment (.releases/cab/<tag>/impact.json)
# to an external documentation system. Invoked by the
# .github/workflows/publish-release-impact.yml "publish" job, which runs
# under the protected `docs-publish` GitHub Environment.
#
# Required environment variables:
#   DOCS_API_URL   - base URL of the external docs system (repo/environment variable)
#   DOCS_API_TOKEN - auth token for the external docs system (environment secret)
#
# This script is intentionally conservative: it validates its inputs, never
# echoes secret values, and does not perform any destructive operations.

set -euo pipefail

usage() {
  echo "Usage: $0 <impact-json-path> <release-tag>" >&2
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

impact_path="$1"
release_tag="$2"

if [ -z "${impact_path}" ] || [ -z "${release_tag}" ]; then
  echo "Error: <impact-json-path> and <release-tag> must both be non-empty." >&2
  usage
  exit 1
fi

if [ ! -f "${impact_path}" ]; then
  echo "Error: impact JSON file not found: ${impact_path}" >&2
  exit 1
fi

if [ -z "${DOCS_API_URL:-}" ]; then
  echo "Error: required environment variable DOCS_API_URL is not set." >&2
  exit 1
fi

if [ -z "${DOCS_API_TOKEN:-}" ]; then
  echo "Error: required environment variable DOCS_API_TOKEN is not set." >&2
  exit 1
fi

# Never echo the token itself. Only report that it is present.
echo "Publishing '${impact_path}' for release '${release_tag}' to external docs system."
echo "Target API: ${DOCS_API_URL}"
echo "Auth token: [present, redacted]"

# TODO: Replace this placeholder with the actual external publishing call
# once the target system's API contract is known. Do not invent a fake
# contract here. Likely shape (adjust to the real API before enabling):
#
#   curl --fail --silent --show-error \
#     --request POST \
#     --header "Authorization: Bearer ${DOCS_API_TOKEN}" \
#     --header "Content-Type: application/json" \
#     --data "@${impact_path}" \
#     "${DOCS_API_URL}/releases/${release_tag}/impact"
#
# Until the real endpoint/payload is confirmed, this script only performs a
# dry-run summary so that CI stays green without silently faking a publish.
echo "Dry-run: no external call made (placeholder implementation, see TODO above)."
