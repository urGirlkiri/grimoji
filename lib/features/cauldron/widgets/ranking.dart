import 'package:flutter/material.dart';
import 'package:grimoji/features/cauldron/widgets/avatar.dart';
import 'package:grimoji/utils/context_data.dart';

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

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = context.theme.textTheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: players
                  .map(
                    (player) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "#${player['rank']}",
                                style: textTheme.displayMedium,
                              ),
                              Text(
                                "(${player['score']})",
                                style: textTheme.labelMedium!.copyWith(
                                  fontSize: 10,
                                  color: palette.magicCyan.withValues(
                                    alpha: .8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Avatar(
                            name: player['name'] as String,
                            scale: 1.0,
                            backgroundColor: palette.dusk.withValues(alpha: .4),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            player['realName'] as String,
                            style: textTheme.bodySmall!.copyWith(
                              color: palette.moonlight.withValues(alpha: .7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
