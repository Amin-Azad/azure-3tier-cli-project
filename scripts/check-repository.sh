#!/usr/bin/env bash

set -euo pipefail

required_files=(
  README.md
  deploy-all.sh
  validate-project.sh
  scripts/00-variables.sh
  scripts/01-resource-group.sh
  scripts/02-networking.sh
  scripts/03-compute.sh
  scripts/04-storage.sh
  scripts/05-iam.sh
  scripts/06-monitoring.sh
  scripts/07-backup.sh
  scripts/cleanup.sh
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || {
    echo "ERROR: missing required file: $file"
    exit 1
  }
done

bash -n deploy-all.sh validate-project.sh scripts/*.sh

if grep -RInE   --exclude='*.png'   --exclude='*.PNG'   --exclude='check-repository.sh'   '(/subscriptions/[0-9a-fA-F-]{36}|[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})'   README.md docs scripts deploy-all.sh validate-project.sh; then
  echo "ERROR: Azure or Entra GUID found in tracked project text."
  exit 1
fi

credential_pattern='(si''g=|Account''Key=|SharedAccess''Signature=)'

if grep -RInE   --exclude='*.png'   --exclude='*.PNG'   --exclude='check-repository.sh'   "$credential_pattern"   README.md docs scripts deploy-all.sh validate-project.sh; then
  echo "ERROR: possible credential material found in tracked project text."
  exit 1
fi

echo "Repository checks passed."
