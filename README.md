<div align="center">

# [Gri[😬️]moji](https://grimoji.io)

A match-3 game that takes inspiration from classics like 2048 and candy crush to form an epic about mixing, merging, matching and collecting emojis.

<img
  src="assets/screenshots/mockup.png"
  alt="Desktop Screenshot"
  style="max-width: 800px; max-height: 800px; object-fit: contain; border-radius: 12px;"
/>

[![App Store](https://img.shields.io/badge/App_Store-0A84FF?style=for-the-badge&logo=app-store&logoColor=white)](https://testflight.apple.com/join/8ryNgWCU)
[![Playstore](https://img.shields.io/badge/Google_Play-0F9D58?style=for-the-badge&logo=googleplay&logoColor=white)](https://play.google.com/store/apps/details?id=io.grimoji.game)
[![macOS](https://img.shields.io/badge/macOS-000000?style=for-the-badge&logo=apple&logoColor=white)](https://testflight.apple.com/join/8ryNgWCU)
[![Microsoft Store](https://img.shields.io/badge/Microsoft_Store-0078D4?style=for-the-badge&logo=data:image/svg%2Bxml;base64,PHN2ZyBmaWxsPSIjRkZGRkZGIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciICB2aWV3Qm94PSIwIDAgNTAgNTAiIHdpZHRoPSI1MHB4IiBoZWlnaHQ9IjUwcHgiPjxwYXRoIGQ9Ik00IDRIMjRWMjRINHpNMjYgNEg0NlYyNEgyNnpNNCAyNkgyNFY0Nkg0ek0yNiAyNkg0NlY0NkgyNnoiLz48L3N2Zz4=&logoColor=white)](https://apps.microsoft.com/detail/9PFZ6M6XMQ2P)
[![Snapcraft](https://img.shields.io/badge/Snap_Store-E95420?style=for-the-badge&logo=snapcraft&logoColor=white)](https://snapcraft.io/grimoji)
[![Web](https://img.shields.io/badge/Web-414141?style=for-the-badge&logo=googlechrome&logoColor=white)](https://play.grimoji.io)
[![Itch.io](https://img.shields.io/badge/Itch.io-FA5C5C?style=for-the-badge&logo=itch.io&logoColor=white)](https://urgirlkiri.itch.io/grimoji)
[![GitHub Releases](https://img.shields.io/badge/GitHub_Releases-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/urGirlkiri/grimoji/releases)

<https://github.com/user-attachments/assets/ceef5a8d-0b00-4a09-b38c-49777ac84560>

## Quick Start

`git clone https://github.com/urGirlkiri/grimoji.git &&
cd grimoji &&
cp .env.example .env &&
flutter pub get &&
flutter run -d chrome`

> See the [setup guide](docs/SETUP.md) for platform-specific setup and run instructions.

## [Documentation](docs/)

<div align="center">

[![Setup](https://img.shields.io/badge/Setup-a6a6bf?style=for-the-badge&logo=bookstack&logoColor=white)](./docs/SETUP.md)
[![Development](https://img.shields.io/badge/Development-8080a4?style=for-the-badge&logo=dart&logoColor=white)](./docs/DEV.md)
[![Running](https://img.shields.io/badge/Running-535373?style=for-the-badge&logo=gnubash&logoColor=white)](./docs/RUNNING.md)
[![Building](https://img.shields.io/badge/Building-333346?style=for-the-badge&logo=flatpak&logoColor=white)](./docs/BUILDING.md)
[![Shipping](https://img.shields.io/badge/Shipping-1a1a24?style=for-the-badge&logo=githubactions&logoColor=white)](./docs/SHIPPING.md)

</div>

## [Core Loops](lib/features/match)

This game revolves around...as you guessed emojis.

There are two main mechanics: `Matches` and `Merges`.

#### _Matches_: Just like Candy Crush, matching 3 or more emojis in any direction destroys stuff

<img
  src="assets/screenshots/match_3.png"
  alt="Match 3 Screenshot"
  style="max-width: 300px; max-height: 300px; object-fit: contain; border-radius: 12px;"
/>

#### _Merges_: Here comes the twist, matching certain emojis will, instead of self-destructing, complete a recipe and merge into a yield [more of that here](lib/features/alchemy/recipe_book.dart)

<img
  src="assets/screenshots/merge_3.png"
  alt="Merge 3 Screenshot"
  style="max-width: 300px; max-height: 300px; object-fit: contain; border-radius: 12px;"
/>

#### _Drop n Merge; Why not? On top of Suika,size accumulating, special emojis when they contact each other, they react and form emoji_ `Its like chemistry in a way`

<img
  src="assets/screenshots/cauldron.png"
  alt="Desktop Screenshot"
  style="max-width: 300px; max-height: 300px; object-fit: contain; border-radius: 12px;"
/>

## [Technologies Used](pubspec.yaml)

**Flutter and Dart**

![rockingdash](https://firebasestorage.googleapis.com/v0/b/dashatar-dev.appspot.com/o/dashatars%2FRGFzaGF0YXJfQm9udXNfU2V0c19Cb251c19E.png?alt=media)

I have fallen in love with Flutter after learning about its superpowers.

Write once, deploy everywhere. I made games before, but I only deployed to the web via itch.io; Flutter gives me the flexibility of one codebase for all platforms.

If you're lazy like me, then this is proof that it's very much possible.

**Provider + Hive**

<img
  src="assets/screenshots/hive_provider.png"
  alt="Desktop Screenshot"
  style="max-width: 300px; max-height: 300px; object-fit: contain; border-radius: 12px;"
/>

For passing data around, what's more intuitive than notifiers? Or maybe it's just that they remind me of Godot Signals. Anyway, if you're coming from there like me, then this stack will be easy: `Provider` is the memory, and `Hive` is the hard drive.

On launch, the app opens Hive boxes for `Settings`, `Level`, and `ProfileData`. I use these boxes to persist settings, level progression and user stuff like your name and avatar. Provider Becomes the bridge, like RAM, it holds all the values in memory, periodically saving them when necessary _(i think)_  i.e if you win a new level or change your avatar ![avatar](assets/avatars/cyber_goth.png).

**Flutter + Flame2D**

![managerdash](https://firebasestorage.googleapis.com/v0/b/dashatar-dev.appspot.com/o/dashatars%2FRGFzaGF0YXJfTWFya2V0aW5nX092ZXJJdF9jb2xvcl9NUl9zaGFkb3c=.png?alt=media)

I thought you might ask. The match-3 grid and its mechanics are built in pure Flutter; the Suika-style cauldron is the onlt place it just makes sense to use a game engine.

For it, i cheated a bit and consulted  `flame` game engine and its `forge2d` mechanics that emulate real world physics. Am still figuring this out so more on that later

For match-3 _(candy crush style)_ see [board mechanics](lib/features/match/board/index) 

### Credits

[Animated Emoji 💖](https://googlefonts.github.io/noto-emoji-animation/) for the emoji animations and SVG icons<br>
[Pixabay](https://pixabay.com/) for the sfx and some music<br>
[Gemini](https://gemini.google.com/) for the music<br>
[Vecteezy](https://vecteezy.com/) for the background and pattern images<br>
[Audjust](https://www.audjust.com/studio) for sfx variations<br>
[Didier Boelens](https://medium.com/flutter-community/flutter-crush-debee5f389c3) for his amazing article on approaching match-3 in flutter<br>
[Mohamed Nasr](https://github.com/mohamedhaloka/Game-Levels-Scrolling-Map) for inspiring me with his game level scrolling map<br>
[Audio Trimmer](https://audiotrimmer.com/) for that extra touch :)<br>
[pikisuperstar on Magnific](https://www.magnific.com/author/pikisuperstar) for the hand drawn mascot

### License & Copyright

The source code of Grimoji is made available under the [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). You are free to study, modify, and self-host the code for personal or educational purposes, but you may **not** use it for any commercial purpose (including ad revenue or paid deployment).

The "Grimoji" brand, custom artwork, UI designs, lore, and sfx are strictly **All Rights Reserved** by Ghetto Coders / Christin Nyakanyanga. They may not be reused or redistributed outside of personal, non-commercial mods of Grimoji itself.
</div>
