// Copyright 2023, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'logic/score.dart';
import 'features/map/screen.dart';
import 'features/map/levels.dart';
import 'features/main_menu.dart';
import 'features/game/level_screen.dart';
import 'features/settings/screen.dart';
import 'widgets/custom_transition_page.dart';
import 'config/palette.dart';
import 'features/game/win_screen.dart';

/// The router describes the game's navigational hierarchy, from the main
/// screen through settings screens all the way to each individual level.
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(key: Key('main menu')),
      routes: [
        GoRoute(
          path: 'play',
          pageBuilder: (context, state) => buildMyTransition<void>(
            key: const ValueKey('play'),
            color: context.watch<Palette>().midnight,
            child: const LevelMapScreen(key: Key('level selection')),
          ),
          routes: [
            GoRoute(
              path: 'session/:level',
              pageBuilder: (context, state) {
                final levelNumber = int.parse(state.pathParameters['level']!);
                final level = gameLevels.singleWhere(
                  (e) => e.number == levelNumber,
                );
                return buildMyTransition<void>(
                  key: const ValueKey('level'),
                  color: context.watch<Palette>().twilight,
                  child: LevelScreen(
                    level,
                    key: const Key('play session'),
                  ),
                );
              },
            ),
            GoRoute(
              path: 'won',
              redirect: (context, state) {
                if (state.extra == null) {
                  // Trying to navigate to a win screen without any data.
                  // Possibly by using the browser's back button.
                  return '/';
                }

                // Otherwise, do not redirect.
                return null;
              },
              pageBuilder: (context, state) {
                final map = state.extra! as Map<String, dynamic>;
                final score = map['score'] as Score;

                return buildMyTransition<void>(
                  key: const ValueKey('won'),
                  color: context.watch<Palette>().twilight,
                  child: WinGameScreen(
                    score: score,
                    key: const Key('win game'),
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) =>
              const SettingsScreen(key: Key('settings')),
        ),
      ],
    ),
  ],
);
