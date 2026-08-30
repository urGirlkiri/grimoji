import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class InsufficientAlert extends StatelessWidget {
  const InsufficientAlert({super.key, required this.needed});

  final int needed;

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    
    return Center(
      child: ScrollDialog(
        scrollType: ScrollType.horizontalShort,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scale,
            vertical: 20 * scale,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/dice.png',
                width: 32 * scale,
                height: 32 * scale,
              ),
              SizedBox(height: 10 * scale),
              Text(
                'Not enough dice!',
                textAlign: TextAlign.center,
                style: context.theme.textTheme.titleMedium?.copyWith(
                  color: palette.moonlight,
                  fontWeight: FontWeight.w900,
                  fontSize: 16 * scale,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                'You need $needed dice for this.',
                textAlign: TextAlign.center,
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: palette.mist,
                  fontSize: 12 * scale,
                ),
              ),
              SizedBox(height: 20 * scale),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      enableAnimation: false,
                      color: palette.slate,
                      fullWidth: false,
                      fontSize: 12 * scale,
                      text: 'Cancel',
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: PillButton(
                      color: palette.twilight,
                      fullWidth: false,
                      text: 'Market',
                      fontSize: 12 * scale,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
