# How to Build Locally

## Android

```bash
flutter build apk --release

```

The release APK is in `build/app/outputs/flutter-apk/app-release.apk`.

## iOS

### Simulator

```bash
flutter build ios --simulator

```

### Release

> **Note:** Signed production `.ipa` files and TestFlight uploads are handled entirely by the `ios-testflight` workflow on Codemagic (see [`DEPLOYING.md`](DEPLOYING.md)). Manual local signing in Xcode is not required.

## macOS

```bash
flutter build macos --release

```

The build output is in `build/macos/Build/Products/Release/grimoji.app`.

### Release

> **Note:** Signed `.pkg` wrappers and Apple notarization are handled entirely by the `macos-testflight` workflow on Codemagic (see [`DEPLOYING.md`](DEPLOYING.md)). Manual `codesign` and `notarytool` commands are not required.

## Windows

```bash
flutter build windows --release

```

The build output is in `build/windows/x64/runner/Release/`.

## Linux

```bash
flutter build linux --release

```

### Debian package

```bash
chmod +x tool/build_deb.sh
./tool/build_deb.sh
sudo dpkg -i grimoji-local.deb

```

## Flatpak

Build a Flatpak package locally:

```bash
flatpak install -y flathub org.flatpak.Builder
flatpak run --command=flatpak-builder org.flatpak.Builder --install . flatpak/io.grimoji.game.yml

```

Or build without installing:

```bash
flatpak-builder --force-clean build-dir flatpak/io.grimoji.game.yml
flatpak-builder --export=repo build-dir flatpak/io.grimoji.game.yml
flatpak build-bundle repo grimoji.flatpak io.grimoji.game

```