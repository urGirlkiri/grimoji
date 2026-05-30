import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: context.palette.midnight,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: CorkScrewCloseButton(),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/question.png'),
              const SizedBox(height: 16),
              Text(
                "Recipe Is Still A Mystery",
                textAlign: TextAlign.center,
                style: context.theme.textTheme.headlineSmall!.copyWith(
                  color: context.palette.moonlight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Continue mixing and matching emojis to discover this recipe.",
                textAlign: TextAlign.center,
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: context.palette.mist,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: PillButton(
                  onTap: () {
                    context.read<LevelDataController>().triggerAutoOpenLevel(level);
                    
                    Navigator.of(context).pop();
                    
                    GoRouter.of(context).goNamed(Routes.map);
                  },
                  text: "Keep Exploring",
                  color: context.palette.twilight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
