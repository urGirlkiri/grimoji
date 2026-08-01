import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:provider/provider.dart';

class LockedDialog extends StatelessWidget {
  const LockedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final level = context.read<LevelDataController>().currentLevel();
    return Dialog(
      backgroundColor: palette.midnight,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: const CorkScrewCloseButton(),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/question.png'),
              const SizedBox(height: 16),
              Text(
                "Continue mixing and matching emojis to discover this recipe.",
                textAlign: TextAlign.center,
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  color: palette.mist,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: PillButton(
                  onTap: () {
                    context.read<LevelDataController>().triggerAutoOpenLevel(
                      level,
                      null,
                    );

                    Navigator.of(context).pop();

                    GoRouter.of(context).goNamed(Routes.map);
                  },
                  text: "Keep Exploring",
                  color: palette.twilight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
