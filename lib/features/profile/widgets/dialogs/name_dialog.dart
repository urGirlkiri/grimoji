import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:grimoji/widgets/painters/rope.dart';

Future<void> showNameDialog(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: context.palette.voidBlack.withValues(alpha: .85),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _NameDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1.2),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog();

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  TextEditingController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= TextEditingController(
      text: context.readProfile.displayName,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _save() {
    final name = (_controller?.text ?? '').trim();
    if (name.isNotEmpty) {
      context.readProfile.setDisplayName(name);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final palette = context.palette;
    final screenHeight = context.screenHeight;
    final dialogTop = (screenHeight * 0.18).clamp(80.0, 200.0);
    final ropeLength = (dialogTop + 65).clamp(80.0, 250.0);

    return Align(
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -50,
            child: CustomPaint(
              size: Size(5, ropeLength),
              painter: const RopePainter(),
            ),
          ),
          Positioned(
            top: dialogTop,
            child: ScrollDialog(
              scrollType: ScrollType.horizontalShort,
              rightButton: CorkScrewCloseButton(
                onTap: () => Navigator.of(context).pop(),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'What\'s  Your Name',
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 16 * scale,
                        color: palette.midnight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.bodyLarge?.copyWith(
                        color: palette.voidBlack,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        hintStyle: context.theme.textTheme.bodyLarge
                            ?.copyWith(color: palette.dusk),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: palette.dusk),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: palette.midnight),
                        ),
                      ),
                      onSubmitted: (_) => _save(),
                    ),
                    SizedBox(height: 12 * scale),
                    AppIcon(
                      fileName: 'confirm_checkmark',
                      size: 45 * scale,
                      onTap: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
