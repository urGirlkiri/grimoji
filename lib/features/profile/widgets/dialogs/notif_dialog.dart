import 'package:flutter/material.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class NotifDialog extends StatelessWidget {
  const NotifDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(child: ScrollDialog(child: const Placeholder()));
  }
}
