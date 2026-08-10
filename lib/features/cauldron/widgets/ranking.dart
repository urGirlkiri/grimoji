import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/cauldron/widgets/avatar.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/breathing_widget.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';

class Ranking extends StatelessWidget {
  const Ranking({super.key});

  static const players = [
    {
      'name': 'cyber_astronaut',
      'realName': 'Zara Flux',
      'score': '2.4k',
      'rank': 1,
    },
    {
      'name': 'fairy_mage',
      'realName': 'Eldrin Moonwhisper',
      'score': '1.9k',
      'rank': 2,
    },
    {
      'name': 'magma_golem',
      'realName': 'Ignatius Stone',
      'score': '1.5k',
      'rank': 3,
    },
    {
      'name': 'fairy_blade',
      'realName': 'Lyra Dawnbringer',
      'score': '1.2k',
      'rank': 4,
    },
    {
      'name': 'paladin_silver',
      'realName': 'Sir Galen Brightshield',
      'score': '980',
      'rank': 5,
    },
  ];

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return palette.magicCyan;
      case 2:
        return palette.moonlight;
      case 3:
        return palette.mist;
      default:
        return palette.slate;
    }
  }

  BoxShadow _getBeginShadow(int rank, double scale) {
    switch (rank) {
      case 1:
        return BoxShadow(
          color: palette.crimson.withValues(alpha: 0.2),
          blurRadius: 8,
          spreadRadius: 0,
          offset: Offset(0, 2 * scale),
        );
      case 2:
        return BoxShadow(
          color: palette.magicCyan.withValues(alpha: 0.15),
          blurRadius: 6,
          spreadRadius: 0,
          offset: Offset(0, 2 * scale),
        );
      case 3:
        return BoxShadow(
          color: palette.twilight.withValues(alpha: 0.1),
          blurRadius: 4,
          spreadRadius: 0,
          offset: Offset(0, 2 * scale),
        );
      default:
        return const BoxShadow(color: Colors.transparent);
    }
  }

  BoxShadow _getEndShadow(int rank, double scale) {
    switch (rank) {
      case 1:
        return BoxShadow(
          color: palette.crimson.withValues(alpha: 0.7),
          blurRadius: 12,
          spreadRadius: 6,
          offset: Offset(0, 4 * scale),
        );
      case 2:
        return BoxShadow(
          color: palette.magicCyan.withValues(alpha: 0.1),
          blurRadius: 4,
          spreadRadius: 3,
          offset: Offset(0, 3 * scale),
        );
      case 3:
        return BoxShadow(
          color: palette.twilight.withValues(alpha: 0.4),
          blurRadius: 2,
          spreadRadius: 1,
          offset: Offset(0, 2 * scale),
        );
      default:
        return const BoxShadow(color: Colors.transparent);
    }
  }

  double _getMaxScale(int rank) {
    switch (rank) {
      case 1:
        return 1.054; 
      case 2:
        return 1.025;
      case 3:
        return 1.015; 
      default:
        return 1.0;
    }
  }

  Duration _getDuration(int rank) {
    switch (rank) {
      case 1:
        return const Duration(milliseconds: 700); 
      case 2:
        return const Duration(milliseconds: 1000); 
      case 3:
        return const Duration(milliseconds: 1200); 
      default:
        return const Duration(milliseconds: 800);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final scale = context.globalScale;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: players.map((player) {
            final rank = player['rank'] as int;
            final rankColor = _rankColor(rank);
            final isTopThree = rank <= 3;
            final cardBorderRadius = BorderRadius.circular(12 * scale);

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0 * scale,
                vertical: 8.0 * scale,
              ),
            child: AnimatedButton(
                child: BreathingWidget(
                  enabled: isTopThree,
                  minScale: 1.0,
                  maxScale: _getMaxScale(rank),
                  duration: _getDuration(rank),
                  borderRadius: cardBorderRadius,
                  beginShadow: _getBeginShadow(rank, scale),
                  endShadow: _getEndShadow(rank, scale),
                  child: Container(
                    width: 160 * scale,
                    padding: EdgeInsets.all(12.0 * scale),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          palette.twilight.withValues(alpha: 0.6),
                          palette.voidBlack.withValues(alpha: 0.95),
                        ],
                      ),
                      borderRadius: cardBorderRadius,
                      boxShadow: [
                        if (!isTopThree)
                          BoxShadow(
                            color: palette.voidBlack,
                            blurRadius: 12,
                            offset: Offset(0, 6 * scale),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale,
                            vertical: 3 * scale,
                          ),
                          child: Text(
                            "#$rank",
                            style: textTheme.labelLarge!.copyWith(
                              color: rankColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        Avatar(
                          name: player['name'] as String,
                          radius: 28 * scale,
                        ),
                        SizedBox(height: 10 * scale),
                        Container(
                          height: 1.5,
                          width: 40 * scale,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                palette.crimson.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        Text(
                          player['realName'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall!.copyWith(
                            color: palette.moonlightSoft,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2 * scale),
                        Text(
                          player['score'] as String,
                          style: textTheme.labelLarge!.copyWith(
                            color: palette.magicCyan,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}