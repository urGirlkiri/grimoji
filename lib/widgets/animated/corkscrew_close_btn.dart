import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';

class CorkScrewCloseButton extends StatefulWidget {
  final double size;
  final String fileName;
  final VoidCallback? onTap;

  const CorkScrewCloseButton({
    super.key,
    this.size = 60.0,
    this.fileName = 'close',
    this.onTap,
  });

  @override
  State<CorkScrewCloseButton> createState() => _CorkScrewCloseButtonState();
}

class _CorkScrewCloseButtonState extends State<CorkScrewCloseButton> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && route.animation != null) {
        if (route.animation!.status == AnimationStatus.completed) {
          setState(() => _isVisible = true);
        } else {
          route.animation!.addStatusListener((status) {
            if (mounted && status == AnimationStatus.completed) {
              setState(() => _isVisible = true);
            }
          });
        }
      } else {
        setState(() => _isVisible = true);
      }
    });
  }

  void _handleTap(VoidCallback onTap) {
    setState(() => _isVisible = false);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: _isVisible ? 1.0 : 0.1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: AnimatedRotation(
          turns: _isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutBack,
          child: AppIcon(
            fileName: widget.fileName,
            size: widget.size,
            enableAnimation: false,
            onTap: () => _handleTap(widget.onTap ?? GoRouter.of(context).pop),
          ),
        ),
      ),
    );
  }
}
