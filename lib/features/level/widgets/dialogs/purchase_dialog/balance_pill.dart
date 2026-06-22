import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class BalancePill extends StatelessWidget {
  const BalancePill({super.key, required this.dices});

  final int dices;

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: palette.twilight,
        shape: BoxShape.rectangle,
        borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/dice.png',
              width: 20 * scale,
              height: 20 * scale,
            ),
            const SizedBox(width: 6),
            Text(
              '$dices',
              style: context.theme.textTheme.bodyLarge?.copyWith(
                color: palette.slate,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}