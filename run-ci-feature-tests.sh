#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

usage() {
  cat <<'EOF'
Usage: run-ci-feature-tests.sh [feature]

Runs the dev container feature tests defined in test-matrix.json.

Arguments:
  feature   Optional. Only run tests for the given feature (e.g. devcontainers-cli).
            When omitted, tests for all features are run.
EOF
}

feature_filter=""
case "${1-}" in
  -h | --help)
    usage
    exit 0
    ;;
  *)
    feature_filter="${1-}"
    ;;
esac

if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' is required but not installed." >&2
  exit 1
fi

if ! command -v devcontainer &> /dev/null; then
  echo "Installing Dev Containers CLI..."
  curl -fsSL https://raw.githubusercontent.com/devcontainers/cli/main/scripts/install.sh | sh
fi

export PATH="$HOME/.devcontainers/bin:$PATH"

combos="$("$REPO_ROOT/scripts/expand-test-matrix.sh" "$feature_filter")"

if [ "$(jq 'length' <<<"$combos")" -eq 0 ]; then
  if [ -n "$feature_filter" ]; then
    echo "No tests found for feature '$feature_filter' in test-matrix.json." >&2
  else
    echo "No tests found in test-matrix.json." >&2
  fi
  exit 1
fi

while IFS=$'\t' read -r feature base_image skip_scenarios; do
  args=(-f "$feature" -i "$base_image")
  scenario_note=""
  if [ "$skip_scenarios" = "true" ]; then
    args+=(--skip-scenarios)
    scenario_note=" (--skip-scenarios)"
  fi
  echo "Running ${feature} on ${base_image}${scenario_note}"
  devcontainer features test "${args[@]}" < /dev/null
done < <(jq -r '.[] | [.feature, .baseImage, .skipScenarios] | @tsv' <<<"$combos")

echo "All CI-equivalent feature tests completed successfully."
