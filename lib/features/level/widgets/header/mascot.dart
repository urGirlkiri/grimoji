import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class Mascot extends StatelessWidget {
  const Mascot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: ShapeDecoration(
        color: context.palette.dusk,
        shape: CircleBorder(
          side: BorderSide(width: 3, color: context.palette.dusk),
        ),
        image: const DecorationImage(
          image: AssetImage("assets/mascot/wizard.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}