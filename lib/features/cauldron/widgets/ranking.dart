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
            final isFirst = rank == 1;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0 * scale,
                vertical: 8.0 * scale,
              ),
              child: AnimatedButton(
                child: BreathingWidget(
                  enabled: isFirst,
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
                      borderRadius: BorderRadius.circular(12 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: isFirst
                              ? palette.magicCyan.withValues(alpha: 0.4)
                              : palette.voidBlack,
                          blurRadius: 12,
                          offset: Offset(0, 6 * scale),
                        ),
                  
                        if (rank <= 3)
                          BoxShadow(
                            color: rankColor.withValues(alpha: 0.15),
                            blurRadius: 10,
                            spreadRadius: -2,
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
