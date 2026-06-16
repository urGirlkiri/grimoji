import 'package:flutter/material.dart';


class WavingMascot extends StatefulWidget {
  const WavingMascot({super.key});

  @override
  State<WavingMascot> createState() => WavingMascotState();
}

class WavingMascotState extends State<WavingMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: 0.1 * _controller.value,
            child: Image.asset('assets/mascot/witch.png', fit: BoxFit.contain),
          );
        },
      ),
    );
  }
}

