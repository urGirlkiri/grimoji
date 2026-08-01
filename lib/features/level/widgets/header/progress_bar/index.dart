import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/level/widgets/header/progress_bar/fill.dart';
import 'package:grimoji/features/level/widgets/header/progress_bar/star_row/index.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.centerLeft,
      children: [_Background(), BarFill(), StarRow()],
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 14,
      decoration: ShapeDecoration(
        color: palette.twilight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
      ),
    );
  }
}
