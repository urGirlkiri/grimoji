import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/market/widgets/powerups/item.dart';
import 'package:grimoji/utils/context_data.dart';

class PowerupSection extends StatelessWidget {
  const PowerupSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<Powerup> items;

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.theme.textTheme.titleMedium?.copyWith(
            color: context.palette.mist,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          subtitle,
          style: context.theme.textTheme.bodySmall?.copyWith(
            color: context.palette.slate,
            fontSize: 12 * scale,
          ),
        ),
        SizedBox(height: 16 * scale),
        ...items.map((boost) => _PowerupShopItem(boost: boost)),
      ],
    );
  }
}

class _PowerupShopItem extends StatelessWidget {
  const _PowerupShopItem({required this.boost});

  final Powerup boost;

  void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? context.palette.crimson
            : context.palette.dusk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: context.palette.moonlight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    final profile = context.readProfile;
    if (profile.spendDice(boost.price)) {
      context.readAudio.playSfx(SfxType.purchase);
      profile.updatePowerupCount(boost.id, boost.bundleAmount);
      _showSnackbar(
        context,
        'Got ${boost.bundleAmount}× ${boost.name}!',
        isError: false,
      );
    } else {
      _showSnackbar(
        context,
        'Need ${boost.price} dice for ${boost.name}!',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final profile = context.readProfile;
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: ListenableBuilder(
        listenable: profile,
        builder: (context, _) {
          final count = profile.getPowerupCount(boost.id);
          return ShopItemCard(
            title: boost.name,
            description: boost.description,
            cost: boost.price,
            iconPath: boost.iconPath,
            lottiePath: boost.lottiePath,
            isEmoji: true,
            amount: '×${boost.bundleAmount}',
            ownedCount: count,
            onTap: () => _onTap(context),
          );
        },
      ),
    );
  }
}
