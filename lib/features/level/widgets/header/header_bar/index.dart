import 'package:flutter/material.dart';
import 'package:grimoji/features/level/widgets/header/header_bar/mascot.dart';
import 'package:grimoji/features/level/widgets/header/header_bar/target_box/index.dart';
import 'package:grimoji/features/level/widgets/header/header_bar/timer.dart';
import 'package:grimoji/utils/context_data.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: context.palette.mist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TimerBox(),
            SizedBox(width: 16),
            TargetBox(),
            SizedBox(width: 16),
            Mascot(),
          ],
        ),
      ),
    );
  }
}
