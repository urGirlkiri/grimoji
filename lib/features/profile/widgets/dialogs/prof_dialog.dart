import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.readProfile;
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
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: context.palette.voidBlack.withValues(alpha: 100),
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
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: context.palette.mist,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Unknown Player",
                              style: context.theme.textTheme.titleSmall
                                  ?.copyWith(color: context.palette.moonlight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: context.palette.slate,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                             "Lv ${level.currentLevel()}",
                              style: context.theme.textTheme.bodyMedium?.copyWith(
                                color: context.palette.moonlightSoft,
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
                "Inventory",
                style: context.theme.textTheme.bodyLarge?.copyWith(
                  color: context.palette.moonlight,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: context.palette.voidBlack,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              GridView.builder(
                shrinkWrap: true, 
                physics:
                    const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio:
                      0.9, 
                ),
                itemCount: Powerup.all.length,
                itemBuilder: (context, index) {
                  final item = Powerup.all[index];
                  final count = profile.getPowerupCount(item.id);

                  return _buildInventoryCard(
                    context: context,
                    name: item.name,
                    iconPath: item.iconPath,
                    count: count,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryCard({
    required BuildContext context,
    required String name,
    required String iconPath,
    required int count,
  }) {
    final bool isEmpty = count <= 0;

    return Container(
      decoration: BoxDecoration(
        color:context.palette.twilight.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmpty ? context.palette.twilight : context.palette.twilight.withValues(alpha: 200),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: isEmpty ? 0.3 : 1.0,
                child: EmojiWidget.svg(path: iconPath, size: 45* context.globalScale),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color:context.palette.mist,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isEmpty
                    ? context.palette.twilight
                    : context.palette.slate,
                shape: BoxShape.circle,
                boxShadow: isEmpty
                    ? []
                    : [
                        BoxShadow(
                          color: context.palette.voidBlack,
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Text(
                count.toString(),
                style: context.theme.textTheme.labelMedium?.copyWith(
                  color: context.palette.moonlight,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
