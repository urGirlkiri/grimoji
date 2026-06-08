import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';

class DailyRewardCard extends StatelessWidget {
  const DailyRewardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final profile = context.watchProfile;
    final palette = context.palette;
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
            backgroundColor: palette.slate,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              "Claimed +15 Dices!",
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: palette.trueWhite,
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
      onPressed = () {
        final dailyText = hours > 0
            ? '$hours Hours'
            : minutes > 0
                ? '$minutes Minutes'
                : '$seconds Seconds';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: palette.slate,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              "Daily Claim available in $dailyText",
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: palette.trueWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      };
    }

    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          palette.twilight.withValues(alpha: 0.25),
          palette.midnight,
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: canClaim ? palette.slate : palette.dusk,
          width: 1,
        ),
        image: DecorationImage(
          image: const AssetImage('assets/images/vertical_lines.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            palette.twilight.withValues(alpha: 0.08),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Free Daily Dices",
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: palette.trueWhite,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              SizedBox(
                width: 95 * scale,
                child: AnimatedButton(
                  onTap: onPressed,
                  enableSound: canClaim,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8 * scale,
                      horizontal: 8 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: canClaim ? palette.mist : palette.dusk,
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(
                        color: canClaim
                            ? palette.trueWhite.withValues(alpha: 0.5)
                            : palette.slate,
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
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        buttonText,
                        style: context.theme.textTheme.bodyLarge?.copyWith(
                          color: canClaim
                              ? palette.midnight
                              : palette.trueWhite,
                          fontWeight: FontWeight.w900,
                        ),
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
                    color: palette.mist,
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
