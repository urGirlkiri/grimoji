import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:grimoji/widgets/painters/rope.dart';

Future<void> showAvatarPicker(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: palette.voidBlack.withValues(alpha: .85),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _AvatarPickerDialog();
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

class _AvatarPickerDialog extends StatelessWidget {
  const _AvatarPickerDialog();

  @override
  Widget build(BuildContext context) {
    final profile = context.watchProfile;
    final scale = context.globalScale;
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
              rightButton: CorkScrewCloseButton(
                onTap: () => Navigator.of(context).pop(),
              ),
              child: Padding(
                padding: EdgeInsets.all(32 * scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Show Us Your Style',
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.headlineMedium?.copyWith(
                        color: palette.midnight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                      itemCount: availableAvatars.length,
                      itemBuilder: (context, index) {
                        final avatar = availableAvatars[index];
                        final isSelected = avatar == profile.avatar;

                        return AnimatedButton(
                          onTap: () {
                            context.readProfile.setAvatar(avatar);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: palette.voidBlack.withValues(
                                alpha: 100,
                              ),
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(
                                color: isSelected
                                    ? palette.moonlight
                                    : palette.dusk.withAlpha(150),
                                width: isSelected ? 3 : 2,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8 * scale),
                              child: Image.asset(
                                'assets/avatars/$avatar.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
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
