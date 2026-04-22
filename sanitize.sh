#!/usr/bin/bash env
set -euo pipefail

rm -rf "pkgs/by-name/op/openclaw"

# refusing to allow a GitHub App to create or update workflow without `workflows` permission
rm -rf ".github"

