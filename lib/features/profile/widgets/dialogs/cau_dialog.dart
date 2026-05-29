import 'package:flutter/material.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class CauldronDialog extends StatelessWidget {
  const CauldronDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: CorkScrewCloseButton(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          children: [
            Text("Repair"),
            Text("Cauldrons")
          ],
                ),
        )));
  }
}
