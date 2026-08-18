import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/router/routes.dart';

class TrailerScreen extends StatefulWidget {
  const TrailerScreen({super.key});

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  static const _prelevelBoosters = ['board_sweep', 'hole', 'ghost', 'wheel'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      GoRouter.of(context).goNamed(
        Routes.levelHint,
        pathParameters: {'level': '1'},
        extra: {'startingBoosters': _prelevelBoosters, 'isTrailer': true},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: palette.midnight,
      body: Center(child: CircularProgressIndicator(color: palette.magicCyan)),
    );
  }
}
