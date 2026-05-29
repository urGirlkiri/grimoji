import 'package:flutter/material.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:provider/provider.dart';

class NotifDialog extends StatelessWidget {
  const NotifDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.watch<Palette>();
    return Dialog(
      insetPadding: EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: CorkScrewCloseButton(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              "No secret messages yet",
              style: theme.textTheme.bodyLarge!.copyWith(
                color: palette.midnight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
