import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mojingo/config/palette.dart'; 

class PowerUps extends StatelessWidget {
  final Palette palette = Palette();

  PowerUps({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: palette.mist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPowerUpBtn("assets/icons/app/pause.png", isSmall: true),
            const SizedBox(width: 12),
            _buildPowerUpBtn("assets/emojis/svg/1f52e.svg"),
            const SizedBox(width: 12),
            _buildPowerUpBtn("assets/emojis/svg/2697.svg"),
            const SizedBox(width: 12),
            _buildPowerUpBtn("assets/emojis/svg/1f3fa.svg"),
            const SizedBox(width: 12),
            _buildPowerUpBtn("assets/emojis/svg/2604_fe0f.svg"),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerUpBtn(String assetPath, {bool isSmall = false}) {
    double size = isSmall ? 60 : 70;
    double iconSize = isSmall ? 60 : 50;
    
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: palette.mist,
        shape: CircleBorder(
          side: BorderSide(width: 3, color: palette.dusk),
        ),
        shadows:  [
          BoxShadow(
            color: palette.midnight, 
            blurRadius: 4,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: assetPath.endsWith('.svg')
            ? SvgPicture.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
              )
            : Image.asset(
                assetPath,
                width: iconSize,
                height: iconSize,
              ),
      ),
    );
  }
}