import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:provider/provider.dart';

class LevelFailDialog extends StatelessWidget {
  final int level;

  const LevelFailDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ScrollDialog(
            rightButton: CorkScrewCloseButton(
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).replaceNamed(Routes.map);
              },
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '-1',
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.displayLarge?.copyWith(
                      color: palette.crimson,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset('assets/images/cauldron_explosion.png'),
                  const SizedBox(height: 12),
                  Text(
                    'The Cauldron exploded!',
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.bodyLarge?.copyWith(
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
                      context.read<LevelDataController>().triggerAutoOpenLevel(
                        level,
                      );
                      GoRouter.of(context).replaceNamed(Routes.map);
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
