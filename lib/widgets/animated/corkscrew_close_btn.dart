import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/widgets/custom/app_icon.dart'; 

class CorkScrewCloseButton extends StatefulWidget {
  final double size;
  final String fileName;
  final VoidCallback ?onTap;

  const CorkScrewCloseButton({
    super.key,
    this.size = 60.0,
    this.fileName = 'close',
    this.onTap ,
  });

  @override
  State<CorkScrewCloseButton> createState() => _CorkScrewCloseButtonState();
}

class _CorkScrewCloseButtonState extends State<CorkScrewCloseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      
      if (route != null && route.animation != null) {
        if (route.animation!.status == AnimationStatus.completed) {
          _controller.forward();
        } else {
          route.animation!.addStatusListener((status) {
            if (mounted && status == AnimationStatus.completed) {
              _controller.forward();
            }
          });
        }
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(VoidCallback onTap) {
    _controller.reverse().then((_) {
      if (mounted) {
        onTap();
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * math.pi,
              child: child,
            ),
          );
        },
        child: AppIcon(
          fileName: widget.fileName,
          size: widget.size,
          enableAnimation: false, 
          onTap: () => _handleTap(widget.onTap ?? GoRouter.of(context).pop),
        ),
      ),
    );
  }
}