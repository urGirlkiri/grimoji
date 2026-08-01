import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class ShopItemCard extends StatelessWidget {
  final String title;
  final String description;
  final int cost;
  final String iconPath;
  final String? lottiePath;
  final VoidCallback onTap;

  final bool isEmoji;
  final String? amount;
  final int? ownedCount;

  const ShopItemCard({
    super.key,
    required this.title,
    required this.description,
    required this.cost,
    required this.iconPath,
    required this.onTap,
    this.lottiePath,
    this.isEmoji = false,
    this.amount,
    this.ownedCount,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          palette.twilight.withValues(alpha: 0.15),
          palette.midnight,
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: palette.slate.withValues(alpha: 0.1),
          width: 1,
        ),
        image: isEmoji
            ? DecorationImage(
                image: const AssetImage('assets/images/vertical_lines.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  palette.midnight.withValues(alpha: 0.05),
                  BlendMode.dstATop,
                ),
              )
            : DecorationImage(
                image: const AssetImage('assets/images/goth_emo.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  palette.voidBlack.withValues(alpha: 0.05),
                  BlendMode.dstATop,
                ),
              ),
        boxShadow: [
          BoxShadow(
            color: palette.voidBlack,
            offset: Offset(0, 6 * scale),
            blurRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: palette.mist,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              AnimatedButton(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: palette.twilight,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: palette.dusk.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.voidBlack,
                        offset: Offset(0, 4 * scale),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/dice.png',
                        width: 18 * scale,
                        height: 18 * scale,
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        cost.toString(),
                        style: context.theme.textTheme.bodyLarge?.copyWith(
                          color: palette.moonlight,
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  isEmoji
                      ? (lottiePath != null
                            ? EmojiWidget(
                                assetPath: lottiePath!,
                                size: 45 * scale,
                              )
                            : EmojiWidget(assetPath: iconPath, size: 45 * scale))
                      : Image.asset(
                          iconPath,
                          width: 45 * scale,
                          height: 45 * scale,
                        ),
                ],
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: palette.mist,
                        fontSize: 13 * scale,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Row(
                      children: [
                        if (ownedCount != null) ...[
                          Text(
                            'Owned: $ownedCount',
                            style: TextStyle(
                              color: ownedCount! > 0
                                  ? palette.magicCyanDeep
                                  : palette.dusk,
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (amount != null)
                          Text(
                            amount!,
                            style: context.theme.textTheme.bodyLarge?.copyWith(
                              color: palette.slate,
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
