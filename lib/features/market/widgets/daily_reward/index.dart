import 'package:flutter/material.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:provider/provider.dart';
import 'state.dart';

class DailyRewardCard extends StatelessWidget {
  const DailyRewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileController, bool>(
      selector: (_, profile) => profile.canClaimDaily(),
      builder: (context, canClaim, _) {
        return RewardTicker(canClaim: canClaim);
      },
    );
  }
}
