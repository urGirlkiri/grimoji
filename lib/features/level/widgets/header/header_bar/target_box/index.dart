import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/level/widgets/header/header_bar/target_box/emoji.dart';

class TargetBox extends StatelessWidget {
  const TargetBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: ShapeDecoration(
        color: palette.dusk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [_Label(), SizedBox(height: 8), TargetEmoji()],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: ShapeDecoration(
        color: palette.slate,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        'Target',
        style: TextStyle(color: palette.trueWhite, fontSize: 14),
      ),
    );
  }
}
