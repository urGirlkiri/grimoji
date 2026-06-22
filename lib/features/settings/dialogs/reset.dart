import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class ResetDialog extends StatelessWidget {
  const ResetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        scrollType: ScrollType.horizontalLong,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Reset Progress?',
              textAlign: TextAlign.center,
              style: context.theme.textTheme.headlineMedium!.copyWith(
                color: palette.midnight,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'This will reset your level progress, cauldrons, and unlocked recipes.',
                textAlign: TextAlign.center,
                style: context.theme.textTheme.bodyMedium!.copyWith(
                  color: palette.midnight,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                PillButton(
                  text: 'Cancel',
                  color: palette.twilight,
                  textColor: palette.mist,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  borderRadius: 20,
                  borderColor: palette.twilight,
                  borderWidth: 3,
                  onTap: () => Navigator.of(context).pop(false),
                ),
                PillButton(
                  text: 'Reset',
                  enableAnimation: false,
                  color: palette.crimson,
                  textColor: palette.trueWhite,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  borderRadius: 20,
                  borderWidth: 3,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
