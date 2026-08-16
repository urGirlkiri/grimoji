# How to Deploy

## Version Change

1. Bump the version in [`pubspec.yaml`](/pubspec.yaml).
2. Mirror the same version in [`snap/snapcraft.yaml`](/snap/snapcraft.yaml).
3. Commit and push to `main`:

```bash
git push origin main
```

## Release flow

Pushing a new version to `main` triggers [`.github/workflows/release.yml`](/.github/workflows/release.yml):

1. `detect-version-change` compares `pubspec.yaml` with the previous commit and outputs `release_version` (the version with the `+build` suffix stripped, e.g. `1.2.3`).
2. `build-and-release` builds Android, Linux, Web, Windows, Snap, and Flatpak and creates the GitHub Release at `v<release_version>`.
3. `build-macos` builds and attaches the unsigned `macos.zip`.
4. `trigger-codemagic` calls the Codemagic API to start `ios-testflight` and `macos-testflight` after the release exists.

## iOS TestFlight

The `ios-testflight` workflow on Codemagic:

- Creates an empty `.env` file.
- Decodes `CERTIFICATE_PRIVATE_KEY` and fetches Apple signing files automatically.
- Builds a signed `.ipa`, renames it to `ios.ipa`, and attaches it to the GitHub Release.
- Publishes the build to TestFlight.

## macOS TestFlight

The `macos-testflight` workflow on Codemagic:

- Creates an empty `.env` file.
- Decodes `CERTIFICATE_PRIVATE_KEY` and fetches macOS App Store and Mac Installer Distribution certificates.
- Builds the `grimoji.app`.
- Creates an unsigned `.pkg` wrapper and signs it securely via `productsign`.
- Publishes the build to TestFlight.

## iOS Simulator Preview

The `ios-simulator-preview` workflow on Codemagic still auto-runs on pushes and pull requests to `main`/`staging`. It builds an unsigned simulator `.app`, zips it, and uploads it to Appetize.io, posting the preview link to GitHub.

## Required secrets

### GitHub `release` environment

Set these in the GitHub `release` environment (or repository secrets):

- `CODEMAGIC_API_TOKEN`
- `CODEMAGIC_APP_ID`
- Existing platform secrets: `KEYSTORE_BASE64`, `STORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`, `SERVICE_ACCOUNT_JSON`, `GOOGLE_CLIENT_ID`, `WINDOWS_USER_MODEL_ID`, `WINDOWS_NOTIFICATION_GUID`, `SNAPCRAFT_TOKEN`, etc.

### Codemagic `Apple` environment group

Set these in the **Codemagic `Apple` environment group**:

- `APPLE_TEAM_ID`
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY` (your `.p8` key, e.g. `AuthKey_*.p8`)
- `CERTIFICATE_PRIVATE_KEY` (Base64-encoded 2048-bit RSA key; run once to generate, then paste the printed value)

### Codemagic `Deploy` environment group

Set these in the **Codemagic `Deploy` environment group**:

- `APPETIZE_API_TOKEN`
- `GITHUB_PAT` (for posting preview links and uploading `ios.ipa`)
