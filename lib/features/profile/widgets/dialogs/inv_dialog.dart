import 'package:flutter/material.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class InventoryDialog extends StatelessWidget {
  const InventoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(child: ScrollDialog(child: const Placeholder()));
  }
}
