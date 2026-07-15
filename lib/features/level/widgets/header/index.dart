import 'package:flutter/material.dart';
import 'package:grimoji/features/level/widgets/header/header_bar/index.dart';
import 'package:grimoji/features/level/widgets/header/progress_row/index.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 230,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [HeaderBar(), ProgressRow()],
      ),
    );
  }
}
