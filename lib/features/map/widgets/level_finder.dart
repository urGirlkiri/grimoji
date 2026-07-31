import 'package:flutter/material.dart';
import 'package:grimoji/features/map/state.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:provider/provider.dart';

class LevelFinder extends StatelessWidget {
  final bool isBelow;
  const LevelFinder({super.key, required this.isBelow});

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final palette = context.palette;

    return AnimatedButton(
    onTap: context.read<MapState>().goToCurrentLv,
      child: Container(
        width: 70 * scale,
        height: 90 * scale,
        decoration: ShapeDecoration(
          color: palette.dusk,
          shape: StarBorder(
            innerRadiusRatio: 0.5,
            points: 3,
            valleyRounding: .13,
            rotation: isBelow ? 180 : 0,
            squash: .92,
            pointRounding: 0.7,
          ),
          shadows: [
            BoxShadow(
              color: palette.crimson.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(1, 5 * scale),
            ),
            BoxShadow(
              color: palette.slate.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 5 * scale),
            ),
            BoxShadow(
              color: palette.midnight,
              offset: Offset(0, 4 * scale),
              blurRadius: 0,
            ),
          ],
        ),
        child: Selector<ProfileController, String>(
          selector: (_, profile) => profile.avatar,
          builder: (context, avatar, _) =>
              Image.asset('assets/avatars/$avatar.png'),
        ),
      ),
    );
  }
}
