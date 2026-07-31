import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/breathing_widget.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class BoosterButton extends StatelessWidget {
  final Powerup item;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const BoosterButton({
    super.key,
    required this.item,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.globalScale;
    final hasInventory = count > 0;

    return BreathingWidget(
      duration: const Duration(milliseconds: 3600),
      maxScale: 1.14,
      enabled: !isSelected && !hasInventory,
      child: AnimatedButton(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 72 * scale,
              height: 72 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: palette.twilight,
                boxShadow: isSelected
                    ? []
                    : [
                        BoxShadow(
                          color: palette.voidBlack.withValues(alpha: .4),
                          offset: const Offset(0, 4),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.only(
                  top: isSelected ? 4.0 : 0.0,
                  bottom: isSelected ? 0.0 : 4.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isSelected
                          ? [palette.twilight, palette.midnight]
                          : [
                              palette.mist.withValues(alpha: .4),
                              palette.twilight,
                            ],
                    ),
                    border: Border.all(
                      color: isSelected
                          ? palette.dusk.withValues(alpha: .7)
                          : palette.mist.withValues(alpha: .1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: hasInventory ? (isSelected ? 1.0 : 0.8) : 0.5,
                      child: EmojiWidget(
                        assetPath: item.iconPath,
                        size: 36 * scale,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (!hasInventory)
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: palette.slate,
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.mist, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: palette.voidBlack.withValues(alpha: 0.45),
                        offset: const Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: palette.moonlight, size: 18),
                  ),
                ),
              )
            else
              Positioned(
                top: -20,
                right: -12,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? palette.twilight
                        : palette.midnight.withValues(alpha: .8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? palette.dusk
                          : palette.mist.withValues(alpha: .1),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: palette.mist, size: 20 * scale)
                      : Text(
                          count.toString(),
                          style: context.theme.textTheme.labelMedium!.copyWith(
                            fontSize: 20 * scale,
                            color: palette.mist,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
