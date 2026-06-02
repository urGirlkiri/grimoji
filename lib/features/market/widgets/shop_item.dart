import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class ShopItemCard extends StatelessWidget {
  final double scale;
  final String title;
  final String description;
  final int cost;
  final String iconPath;
  final VoidCallback onTap;

  const ShopItemCard({
    super.key,
    required this.scale,
    required this.title,
    required this.description,
    required this.cost,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          context.palette.twilight.withValues(alpha: 0.15),
          context.palette.midnight,
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: context.palette.slate.withValues(alpha: 0.1),
          width: 1,
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/goth_emo.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            context.palette.voidBlack.withValues(alpha: 0.05),
            BlendMode.dstATop,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.palette.voidBlack,
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
                    color: context.palette.mist,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.palette.twilight,
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                ),
                onPressed: onTap,
                icon: Image.asset(
                  'assets/images/dice.png',
                  width: 18 * scale,
                  height: 18 * scale,
                ),
                label: Text(
                  cost.toString(),
                  style: context.theme.textTheme.bodyLarge?.copyWith(
                    color: context.palette.moonlight,
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),

          Row(
            children: [
              Image.asset(iconPath, width: 45 * scale, height: 45 * scale),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  description,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.palette.mist,
                    fontSize: 13 * scale,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
