import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class DailyRewardCard extends StatelessWidget {
  final double scale;

  const DailyRewardCard({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final profile = context.watchProfile;
    final canClaim = profile.canClaimDaily();
    final timeUntil = profile.timeUntilNextDailyClaim();

    String buttonText;
    VoidCallback? onPressed;

    if (canClaim) {
      buttonText = "Claim";
      onPressed = () {
        profile.claimDailyReward();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: context.palette.slate,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              "Claimed +15 Dices!",
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.palette.trueWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      };
    } else {
      final hours = timeUntil.inHours;
      final minutes = timeUntil.inMinutes % 60;
      final seconds = timeUntil.inSeconds % 60;
      buttonText =
          "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      onPressed = null;
    }

    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          context.palette.twilight.withValues(alpha: 0.25),
          context.palette.midnight,
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: canClaim ? context.palette.slate : context.palette.dusk,
          width: 1,
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/vertical_lines.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            context.palette.twilight.withValues(alpha: 0.08),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Free Daily Dices",
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: context.palette.trueWhite,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              SizedBox(
                width: 95 * scale,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: canClaim
                        ? context.palette.mist
                        : context.palette.dusk,
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                  ),
                  onPressed: onPressed,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonText,
                      style: context.theme.textTheme.bodyLarge?.copyWith(
                        color: canClaim
                            ? context.palette.midnight
                            : context.palette.trueWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),

          Row(
            children: [
              Image.asset(
                'assets/images/dice.png',
                width: 50 * scale,
                height: 50 * scale,
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  canClaim
                      ? "+15 magical dices to spend in the bazaar."
                      : "Next claim available when the timer finishes.",
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
