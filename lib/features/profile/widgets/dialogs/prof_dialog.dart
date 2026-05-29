import 'package:flutter/material.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(child: const Placeholder()));
  }
}
