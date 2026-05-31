#!/usr/bin/env bash
# Expands test-matrix.json into a flat JSON array of test combinations.
# Each element is: { "feature": "...", "baseImage": "...", "skipScenarios": true|false }
#
# Usage:
#   expand-test-matrix.sh [feature]
#
# If [feature] is provided, only combinations for that feature are emitted.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MATRIX_FILE="${MATRIX_FILE:-$REPO_ROOT/test-matrix.json}"

if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' is required but not installed." >&2
  exit 1
fi

if [ ! -f "$MATRIX_FILE" ]; then
  echo "Error: matrix file not found: $MATRIX_FILE" >&2
  exit 1
fi

feature_filter="${1-}"

jq -c --arg feature "$feature_filter" '
  [
    .groups[]
    | .skipScenarios as $skip
    | .baseImages as $images
    | .features[]
    | . as $f
    | $images[]
    | { feature: $f, baseImage: ., skipScenarios: $skip }
  ]
  | if $feature == "" then . else map(select(.feature == $feature)) end
' "$MATRIX_FILE"
