# Coplace — iOS 2D Exploration Game

Coplace is a SwiftUI-based 2D exploration prototype. It uses a large scrollable world, a touch joystick, collectible discoveries, a map sheet, and local save data.

## Features

- Continuous joystick movement (not movement only when the finger moves).
- Camera follows the player and clamps to the world boundaries.
- Six collectibles placed around Sunny Meadow.
- Collection progress and player position are saved with `UserDefaults`.
- Discovery list and reset option in the map sheet.
- iOS 16.0 minimum deployment target.
- No third-party packages or external assets required.

## Project

Open `Coplace.xcodeproj` in Xcode and select the `Coplace` scheme.

Bundle identifier: `com.doni.coplace`

## GitHub Actions

The workflow `.github/workflows/build-ipa.yml` runs two jobs:

1. `validate` builds the app for the iOS Simulator without signing.
2. `build-ipa` archives the app for iOS and exports an Ad Hoc signed IPA.

The IPA job requires a valid Apple Distribution certificate and an Ad Hoc provisioning profile that matches `com.doni.coplace`.

### Required GitHub repository secrets

| Secret | Value |
|---|---|
| `IOS_CERTIFICATE_BASE64` | Base64-encoded Apple Distribution `.p12` file |
| `IOS_CERTIFICATE_PASSWORD` | Password used when exporting the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded Ad Hoc `.mobileprovision` file |
| `IOS_TEAM_ID` | Your 10-character Apple Developer Team ID |

### Create Base64 values on Windows PowerShell

Run these commands locally. Do not upload the original certificate or profile into the repository.

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes(".\distribution.p12")) | Set-Content -NoNewline ".\certificate-base64.txt"
[Convert]::ToBase64String([IO.File]::ReadAllBytes(".\profile.mobileprovision")) | Set-Content -NoNewline ".\profile-base64.txt"
```

Copy the contents of each text file into its corresponding GitHub Actions secret. Keep the `.p12` file, its password, and the provisioning profile private.

### Run the build

Push the project to the `main` branch, or open **GitHub → Actions → Coplace iOS CI and IPA → Run workflow**.

When the workflow succeeds, open the run and download the `Coplace-IPA` artifact.

## Important signing notes

- The workflow creates an **Ad Hoc** IPA. The provisioning profile must be an Ad Hoc profile for this bundle identifier.
- Ad Hoc installation is limited to devices registered in that profile.
- A valid Apple signing certificate and provisioning profile are required. GitHub Actions cannot create or replace Apple's signing credentials.
- The project has been statically checked in this environment, but the actual Xcode build and signed IPA export must be confirmed by running the GitHub Actions workflow.
