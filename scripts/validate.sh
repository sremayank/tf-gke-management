#!/usr/bin/env bash
set -euo pipefail

terraform fmt -check -recursive
tflint --recursive

for env_dir in live/*; do
  [ -d "${env_dir}" ] || continue
  terraform -chdir="${env_dir}" init -backend=false
  terraform -chdir="${env_dir}" validate
done

checkov --directory . --framework terraform --quiet
