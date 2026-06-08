import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/utils/math.dart';

class Mascot extends StatelessWidget {
  const Mascot({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none, 
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.palette.dusk,
              shape: BoxShape.circle,
              border: Border.all(
                width: 3, 
                color: context.palette.dusk,
              ),
            ),
          ),
          
          Positioned(
            bottom: -10, 
            width: 80, 
            height: 80, 
            child: Transform.rotate(
              angle: degToRad(-10),
              child: Image.asset(
                "assets/mascot/witch.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}