import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/profile/widgets/dialogs/avatar_dialog.dart';
import 'package:grimoji/features/profile/widgets/dialogs/inventory_card.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watchProfile;
    final level = context.read<LevelDataController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: const CorkScrewCloseButton(),
        child: Padding(
          padding: EdgeInsets.all(32 * context.globalScale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    AnimatedButton(
                      onTap: () => showAvatarPicker(context),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: context.palette.voidBlack.withValues(
                            alpha: 100,
                          ),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.palette.dusk.withAlpha(150),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/avatars/${profile.avatar}.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedButton(
                              child: Icon(
                                Icons.person,
                                color: context.palette.moonlight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Unknown Player",
                              style: context.theme.textTheme.titleSmall
                                  ?.copyWith(color: context.palette.mist),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedButton(
                              child: Icon(
                                Icons.stars_rounded,
                                color: context.palette.moonlight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Lv ${level.currentLevel()}",
                              style: context.theme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: context.palette.mist,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                "Cascet",
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  color: context.palette.midnight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: Powerup.all.length,
                  itemBuilder: (context, index) {
                    final item = Powerup.all[index];
                    final count = profile.getPowerupCount(item.id);

                    return InventoryCard(
                      context: context,
                      id: item.id,
                      name: item.name,
                      iconPath: item.iconPath,
                      count: count,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
