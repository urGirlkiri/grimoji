import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/router/layout/shell_tab.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/features/market/widgets/daily_reward/content.dart';

class RewardTicker extends StatefulWidget {
  final bool canClaim;

  const RewardTicker({super.key, required this.canClaim});

  @override
  State<RewardTicker> createState() => _RewardTickerState();
}

class _RewardTickerState extends State<RewardTicker> {
  static const int _marketBranchIndex = 3;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant RewardTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.canClaim != widget.canClaim) {
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    final isMarketTab =
        ShellTabScope.maybeOf(context)?.isBranchActive(_marketBranchIndex) ??
        true;

    if (!isMarketTab || widget.canClaim) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.readProfile;
    final timeUntil = profile.timeUntilNextDailyClaim();

    return CardContent(
      canClaim: widget.canClaim,
      timeUntil: timeUntil,
      onClaimPressed: () async {
        final isFirstClaim = profile.lastDailyClaimTime == 0;
        profile.claimDailyReward();
        if (isFirstClaim) {
          final reminder = context.readDailyClaimReminder;
          await reminder.requestPermission();
          await reminder.rescheduleFromProfile(profile);
        }
        if (!context.mounted) return;
        _showSnackBar(context, "Claimed +15 Dices!");
      },
      onLockedPressed: (String timeInTxt) {
        _showSnackBar(context, "Daily Claim available in $timeInTxt");
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.slate,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          message,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: palette.trueWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
