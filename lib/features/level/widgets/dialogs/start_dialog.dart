import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/level/widgets/dialogs/purchase_dialog/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/breathing_widget.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class LevelStartDialog extends StatefulWidget {
  final GameLevel level;

  const LevelStartDialog({super.key, required this.level});

  @override
  State<LevelStartDialog> createState() => _LevelStartDialogState();
}

class _LevelStartDialogState extends State<LevelStartDialog> {
  final Set<String> _selectedPowerupIds = {};

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.globalScale;
    final profile = context.readProfile;

    final prelevelItems = Powerup.all.where((p) => p.isPrelevel).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: const CorkScrewCloseButton(),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Level ${widget.level.number}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.eagleLake(
                    color: palette.midnight,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                EmojiWidget.lottie(
                  path: widget.level.targetEmoji.lottie,
                  useDropShadow: true,
                  size: 100,
                ),
                const SizedBox(height: 24),

                Text(
                  "Select Boosters:",
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: palette.mist,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: prelevelItems.map((item) {
                    final count = profile.getPowerupCount(item.id);
                    final hasInventory = count > 0;
                    final isSelected = _selectedPowerupIds.contains(item.id);

                    return BreathingWidget(
                      duration: const Duration(milliseconds: 3600),
                      maxScale: 1.14,
                      enabled: !isSelected && !hasInventory,
                      child: AnimatedButton(
                        onTap: () async {
                          if (!hasInventory) {
                            final purchased = await showBoostPurchase(
                              context,
                              item,
                            );
                            if (purchased && mounted) {
                              setState(() {});
                            }
                            return;
                          }

                          setState(() {
                            if (isSelected) {
                              _selectedPowerupIds.remove(item.id);
                            } else {
                              _selectedPowerupIds.add(item.id);
                            }
                          });
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 64 * scale,
                              height: 64 * scale,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: palette.twilight,
                                boxShadow: isSelected
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: palette.voidBlack.withValues(
                                            alpha: .4,
                                          ),
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
                                              palette.mist.withValues(
                                                alpha: .4,
                                              ),
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
                                      opacity: hasInventory
                                          ? (isSelected ? 1.0 : 0.8)
                                          : 0.5,
                                      child: EmojiWidget.svg(
                                        path: item.iconPath,
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
                                    border: Border.all(
                                      color: palette.mist,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: palette.voidBlack.withValues(
                                          alpha: 0.45,
                                        ),
                                        offset: const Offset(0, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: palette.moonlight,
                                      size: 18,
                                    ),
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
                                        : palette.midnight.withValues(
                                            alpha: .8,
                                          ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: palette.dusk,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: palette.mist,
                                          size: 20 * scale,
                                        )
                                      : Text(
                                          count.toString(),
                                          style: context
                                              .theme
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
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
                  }).toList(),
                ),
                const SizedBox(height: 32),

                PillButton(
                  text: "MIX IT",
                  color: palette.twilight,
                  textColor: palette.mist,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  borderRadius: 20,
                  borderColor: palette.twilight,
                  borderWidth: 3,
                  onTap: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).replaceNamed(
                      Routes.levelHint,
                      pathParameters: {'level': widget.level.number.toString()},
                      extra: {'startingBoosters': _selectedPowerupIds.toList()},
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
