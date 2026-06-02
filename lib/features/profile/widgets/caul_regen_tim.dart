import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/utils/context_data.dart';

class CaulRegenTim extends StatefulWidget {
  const CaulRegenTim({super.key});

  @override
  State<CaulRegenTim> createState() => _CaulRegenTimState();
}

class _CaulRegenTimState extends State<CaulRegenTim> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        context.readProfile.checkCauldronRegen();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeUntil = context.readProfile.timeUntilNextCauldron();
    
    if (timeUntil == Duration.zero) {
      return const SizedBox.shrink(); 
    }

    final hours = timeUntil.inHours;
    final minutes = timeUntil.inMinutes % 60;
    final seconds = timeUntil.inSeconds % 60;

    final vMin = minutes.toString().padLeft(2, '0');
    final vSec = seconds.toString().padLeft(2, '0');

    final timeString = hours > 0 
        ? "$hours:$vMin:$vSec"
        : "$vMin:$vSec";

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Container(
        height: 50 * context.globalScale, 
        decoration: BoxDecoration(
          color: context.palette.slate,
          borderRadius: BorderRadius.circular(20 * context.globalScale),
          border: Border.all(
            color: context.palette.twilight,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: context.palette.voidBlack,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              color: context.palette.twilight,
              size: 32 * context.globalScale,
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).rotate(
              duration: const Duration(seconds: 2),
              curve: Curves.linear,
              begin: 0,
              end: 1,
            ),
            SizedBox(width: 8 * context.globalScale),
            
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Next in $timeString",
                  maxLines: 1,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: context.palette.moonlight,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}