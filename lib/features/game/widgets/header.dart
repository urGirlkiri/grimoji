import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:mojingo/config/palette.dart';

class Header extends StatelessWidget {
  static const double progress = 0.65;
  final int level;

  final Palette palette = Palette();

  Header({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: palette.mist,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoBox('Moves', '10'),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoBox('Target', 'assets/emojis/svg/2601.svg', isEmoji: true),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: ShapeDecoration(
                  color: palette.dusk,
                  shape: CircleBorder(
                    side: BorderSide(width: 3, color: palette.dusk),
                  ),
                  image: const DecorationImage(
                    image: AssetImage("assets/mascot/wizard.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildProgressbar(),
      ],
    );
  }

  Widget _buildProgressbar() {
    return Row(
      children: [
        Text(
          'Level $level',
          style: TextStyle(
            color: palette.trueWhite,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: double.infinity,
                height: 12,
                decoration: ShapeDecoration(
                  color: palette.twilight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: ShapeDecoration(
                    color: palette.mist,
                    // TODO: change color if active(when actively triggering combos n updating progress) to moonlight
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStar(isActive: progress >= 0.25),
                  _buildStar(isActive: progress >= 0.50),
                  _buildStar(isActive: progress >= 0.75),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String label, String value, {bool isEmoji = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: ShapeDecoration(
        color: palette.dusk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: ShapeDecoration(
              color: palette.slate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(color: palette.trueWhite, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          
          isEmoji
              ? DropShadow(
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                  color: palette.midnight,
                  child: SvgPicture.asset(
                    value, 
                    width: 32,
                    height: 32,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    color: palette.trueWhite,
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStar({required bool isActive}) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.3,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/level/star.png"),
          ),
        ),
      ),
    );
  }
}