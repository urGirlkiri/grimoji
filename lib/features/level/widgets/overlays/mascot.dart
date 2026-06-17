import 'package:flutter/material.dart';

class WavingMascot extends StatelessWidget {
  const WavingMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset('assets/mascot/celebration.webp', fit: BoxFit.contain),
    );
  }
}
