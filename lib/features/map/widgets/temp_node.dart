import 'package:flutter/material.dart';

class TempNode extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isCursorMode;

  const TempNode({super.key, 
    required this.child,
    required this.onTap,
    required this.isCursorMode,
  });

  @override
  State<TempNode> createState() => TempNodeState();
}

class TempNodeState extends State<TempNode> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: widget.isCursorMode ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.isCursorMode ? widget.onTap : null,
        child: AbsorbPointer( 
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: (_isHovering && widget.isCursorMode)
                  ? [
                      BoxShadow(
                        color: Colors.red.withValues(alpha:0.8),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (_isHovering && widget.isCursorMode)
                  ? Colors.red.withValues(alpha:0.5)
                  : Colors.transparent,
            ),
            child: Opacity(
              opacity: widget.isCursorMode ? 1.0 : 0.6,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}