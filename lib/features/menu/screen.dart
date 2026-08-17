import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/menu/widgets/menu_btns.dart';


class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  static const _xPaddle = 40.0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: palette.midnight,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/room.jpeg', fit: BoxFit.cover),
          ),
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _xPaddle),
              child: Center(
                child: Image.asset(
                  'assets/images/text_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
         const MenuBtns()
        ],

      ),
    );
  }
}
