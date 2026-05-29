# How to Build Locally

## Android

```bash
flutter build apk --release
```

## iOS

```bash
flutter build ipa --release
```

## Windows

```bash
flutter build windows --release
```

## Linux

```bash
flutter build linux --release
```

To build a `.deb` package:

```bash
chmod +x ./tools/build_deb.sh
./tools/build_deb.sh
sudo dpkg -i grimoji-local.deb
```

## macOS

```bash
flutter build macos
```

## Flatpak

Build a Flatpak package locally:

```bash
flatpak install -y flathub org.flatpak.Builder
flatpak run --command=flatpak-builder org.flatpak.Builder --install . io.grimoji.game.yml
```

Or build without installing:

```bash
flatpak-builder --force-clean build-dir io.grimoji.game.yml
flatpak-builder --export=repo build-dir io.grimoji.game.yml
flatpak build-bundle repo grimoji.flatpak io.grimoji.game
```