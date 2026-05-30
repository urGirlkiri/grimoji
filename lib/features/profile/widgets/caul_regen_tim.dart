import 'dart:async';

import 'package:flutter/material.dart';
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
        height: 50,
        decoration: BoxDecoration(
          color: context.palette.slate,
          borderRadius: BorderRadius.circular(20),
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
            AnimatedRotation(
              turns: timeUntil.inSeconds / 2, 
              duration: const Duration(seconds: 1),
              child: Icon(
                Icons.hourglass_empty_rounded,
                color: context.palette.twilight,
                size: 32,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 170,
              child: Text(
                "Next in $timeString",
                style: context.theme.textTheme.titleMedium?.copyWith(
                  color: context.palette.moonlight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}