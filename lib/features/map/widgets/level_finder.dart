import 'package:flutter/material.dart';
import 'package:grimoji/features/map/state.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:provider/provider.dart';

class LevelFinder extends StatefulWidget {
  const LevelFinder({super.key});

  @override
  State<LevelFinder> createState() => _LevelFinderState();
}

class _LevelFinderState extends State<LevelFinder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _bounce;
  bool? _lastIsBelow;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounce = Tween<double>(begin: 0, end: 14).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final palette = context.palette;

    return Selector<MapState, bool?>(
      selector: (_, state) => state.isBelowLevel,
      builder: (context, isBelow, _) {
        final bool isVisible = isBelow != null;
        final bool? hintBelow = isBelow ?? _lastIsBelow;
        if (isBelow != null) _lastIsBelow = isBelow;

        return AnimatedPositioned(
          duration: Durations.medium1,
          curve: Curves.easeOut,
          top: hintBelow == false ? 13.0 : null,
          bottom: hintBelow == true ? 13.0 : null,
          left: (context.screenWidth / 2) - 44,
          child: AnimatedOpacity(
            duration: Durations.short3,
            opacity: isVisible ? 1.0 : 0.0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final direction = hintBelow == true ? 1.0 : -1.0;
                return Transform.translate(
                  offset: Offset(0, _bounce.value * direction),
                  child: child!,
                );
              },
              child: AnimatedButton(
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
                      rotation: hintBelow == true ? 180 : 0,
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
              ),
            ),
          ),
        );
      },
    );
  }
}
