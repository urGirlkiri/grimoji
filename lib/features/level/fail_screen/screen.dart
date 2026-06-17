import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/level/fail_screen/dialog.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';

class LevelFailScreen extends StatefulWidget {
  final int level;

  const LevelFailScreen({super.key, required this.level});

  @override
  State<LevelFailScreen> createState() => _LevelFailScreenState();
}

class _LevelFailScreenState extends State<LevelFailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.readAudio.playMenuMusic();
      _showFailDialog();
      context.readProfile.spendCauldron();
    });
  }

  void _showFailDialog() {
    showAnimatedDialog(
      context,
      LevelFailDialog(level: widget.level),
      barrierDismissible: false,
    );
  }

  void _navigateToMap() {
    GoRouter.of(context).pop();
    GoRouter.of(context).replaceNamed(Routes.map);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateToMap();
      },
      child: Scaffold(
        backgroundColor: palette.midnight,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(color: palette.twilight),
              child: Center(
                child: Image.asset(
                  'assets/images/emo_3.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
