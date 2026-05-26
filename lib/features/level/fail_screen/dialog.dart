import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/widgets/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:grimoji/widgets/pill_button.dart';
import 'package:grimoji/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

class LevelFailDialog extends StatelessWidget {
  final int level;

  const LevelFailDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ScrollDialog(
            rightButton: CorkScrewCloseButton(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  EmojiWidget.lottie(
                    path: Emojis.collision.lottie,
                    size: 90,
                    useDropShadow: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The mixture exploded!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: palette.twilight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  PillButton(
                    text: 'Retry Level $level',
                    color: palette.crimson,
                    textColor: palette.trueWhite,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    borderRadius: 20,
                    borderColor: palette.midnight,
                    borderWidth: 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).goNamed(
                        Routes.map,
                        queryParameters: {'autoOpen': level.toString()},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
