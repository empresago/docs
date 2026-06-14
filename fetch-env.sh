#!/usr/bin/env bash
# Entry point Unix / Git Bash → dispatcher Node escolhe o script do SO.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "${ROOT}/scripts/fetch-env/run.cjs"
