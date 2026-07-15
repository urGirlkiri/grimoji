import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/level/widgets/dialogs/purchase_dialog/index.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog/booster.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
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
    final profile = context.readProfile;

    final prelevelItems = Powerup.all.where((p) => p.isPrelevel).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: const CorkScrewCloseButton(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Level ${widget.level.number}",
                textAlign: TextAlign.center,
                style: context.theme.textTheme.headlineLarge?.copyWith(
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
              const SizedBox(height: 50),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.0 * context.globalScale,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: prelevelItems.map((item) {
                    final count = profile.getPowerupCount(item.id);
                    final hasInventory = count > 0;
                    final isSelected = _selectedPowerupIds.contains(item.id);

                    return BoosterButton(
                      item: item,
                      count: count,
                      isSelected: isSelected,
                      onTap: () async {
                        if (!hasInventory) {
                          final purchased = await showBoostPurchase(
                            context,
                            item,
                          );
                          if (purchased == null) {
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            return;
                          }
                          if (purchased == true) {
                            setState(() {
                              _selectedPowerupIds.add(item.id);
                            });
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
                    );
                  }).toList(),
                ),
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
    );
  }
}
