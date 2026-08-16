#!/usr/bin/env bash
# Setup the GitHub "release" environment for the grimoji workflow.
#
# This script uses `gh` to:
# - create the `release` environment
# - lock it to the `main` branch
# - add you as a required reviewer
# - move the listed secrets from repo-level to the `release` environment
#
# Usage:
#   export KEYSTORE_BASE64="..."
#   export STORE_PASSWORD="..."
#   ... (set the rest)
#   bash tool/setup_release_env.sh
#
# For secrets with newlines (e.g. SERVICE_ACCOUNT_JSON), set them from a file:
#   export SERVICE_ACCOUNT_JSON="$(cat service-account.json)"

set -euo pipefail

if ! gh auth status >/dev/null 2>&1; then
  echo "Error: 'gh' is not authenticated. Run 'gh auth login' first."
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Using repository: $REPO"

echo "Creating 'release' environment for main only with admin bypass..."
gh api --method PUT "repos/$REPO/environments/release" --input - <<EOF
{
  "wait_timer": 0,
  "reviewers": [],
  "can_admins_bypass": true,
  "deployment_branch_policy": {
    "protected_branches": false,
    "custom_branch_policies": true
  }
}
EOF

echo "Locking 'release' environment to the main branch..."
gh api --method POST "repos/$REPO/environments/release/deployment-branch-policies" --input - <<EOF
{
  "name": "main"
}
EOF

# Secrets that the workflow now reads from the `release` environment
SECRETS=(
  KEYSTORE_BASE64
  STORE_PASSWORD
  KEY_PASSWORD
  KEY_ALIAS
  SERVICE_ACCOUNT_JSON
  ANDROID_IAP_KEY
  IOS_IAP_KEY
  GOOGLE_CLIENT_ID
  SUPABASE_URL
  SUPABASE_ANON_KEY
  WINDOWS_USER_MODEL_ID
  WINDOWS_NOTIFICATION_GUID
  FACEBOOK_APP_ID
  WEB_URL
  RESEND_API_KEY
  REWARDED_AD_ID
  BANNER_AD_ID
  SNAPCRAFT_TOKEN
  CODEMAGIC_API_TOKEN
  CODEMAGIC_APP_ID
)

for secret in "${SECRETS[@]}"; do
  value="${!secret:-}"
  if [ -z "$value" ]; then
    echo "Skipping $secret (not set)"
    continue
  fi
  echo "Setting $secret..."
  gh secret set "$secret" --env release --body "$value"
done

echo "Done. 'release' environment is configured for main-branch-only, reviewer-protected releases."
echo ""
echo "IMPORTANT: GitHub only stores these secrets."
echo "You must still configure the following Codemagic environment groups manually:"
echo ""
echo "  Apple group:"
echo "    - APPLE_TEAM_ID"
echo "    - APP_STORE_CONNECT_KEY_IDENTIFIER"
echo "    - APP_STORE_CONNECT_ISSUER_ID"
echo "    - APP_STORE_CONNECT_PRIVATE_KEY"
echo "    - CERTIFICATE_PRIVATE_KEY (Base64 of the 2048-bit cert key printed by a build)"
echo ""
echo "  Deploy group:"
echo "    - APPETIZE_API_TOKEN"
echo "    - GITHUB_PAT"
