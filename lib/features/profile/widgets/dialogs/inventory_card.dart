import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/widgets/dialogs/purchase_dialog/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class InventoryCard extends StatelessWidget {
  const InventoryCard({
    super.key,
    required this.context,
    required this.name,
    required this.iconPath,
    required this.count,
    required this.id,
  });

  final BuildContext context;
  final String name;
  final String iconPath;
  final int count;
  final String id;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bool isEmpty = count <= 0;
    final boost = Powerup.byId(id);

    return AnimatedButton(
      onTap: () {
        showBoostPurchase(context, boost!);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: palette.midnight,
          boxShadow: [
            BoxShadow(
              color: palette.voidBlack.withValues(alpha: 0.6),
              offset: const Offset(0, 6),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette.slate.withValues(alpha: 0.8),
                  palette.twilight,
                  palette.dusk,
                ],
                stops: const [0.0, 0.15, 1.0],
              ),
              border: Border.all(
                color: palette.mist.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 8),

                Expanded(
                  child: Opacity(
                    opacity: isEmpty ? 0.4 : 1.0,
                    child: Center(
                      child: EmojiWidget.svg(
                        path: iconPath,
                        size: 55 * context.globalScale,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    bottom: 12.0,
                  ),
                  child: Container(
                    height: 32 * context.globalScale,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: palette.midnight.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: palette.mist.withValues(alpha: 0.3),
                          offset: const Offset(0, 1.5),
                          blurRadius: 0,
                        ),
                        BoxShadow(
                          color: palette.midnight,
                          offset: const Offset(0, -1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isEmpty ? 0 : 8.0),
                      child: Center(
                        child: Text(
                          count.toString(),
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            color: isEmpty ? palette.dusk : palette.slate,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            fontSize: 18 * context.globalScale,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
