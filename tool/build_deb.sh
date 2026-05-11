#!/bin/bash

rm -rf debian_build
mkdir -p debian_build/usr/share/grimoji
mkdir -p debian_build/usr/bin
mkdir -p debian_build/DEBIAN
mkdir -p debian_build/usr/share/applications
mkdir -p debian_build/usr/share/pixmaps

cp -r build/linux/x64/release/bundle/* debian_build/usr/share/grimoji/

ln -s /usr/share/grimoji/Grimoji debian_build/usr/bin/grimoji

cp assets/icons/icon.png debian_build/usr/share/pixmaps/grimoji.png

cat <<EOF > debian_build/usr/share/applications/grimoji.desktop
[Desktop Entry]
Version=1.0
Name=Grimoji
Comment=A Magical Match-3 Alchemy Game
Exec=/usr/bin/grimoji
Icon=grimoji
Terminal=false
Type=Application
Categories=Game;LogicGame;
EOF

cat <<EOF > debian_build/DEBIAN/control
Package: grimoji
Version: 1.0.0
Architecture: amd64
Maintainer: Grimoji <youremail@example.com>
Description: A Magical Match-3 Alchemy Game
EOF

dpkg-deb --build debian_build grimoji-local.deb
