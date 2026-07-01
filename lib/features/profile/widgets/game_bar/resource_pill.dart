import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';

class ResourcePill extends StatelessWidget {
  final String iconPath;
  final String value;
  final VoidCallback onTap;
  final bool expanded;

  const ResourcePill({
    super.key,
    required this.iconPath,
    required this.value,
    required this.onTap,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.globalScale;

    final Widget pill = AnimatedButton(
      onTap: onTap,
      child: SizedBox(
        height: 55 * scale,
        child: Stack(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 20 * scale,
              right: 0,
              child: Container(
                height: 28 * scale,
                decoration: BoxDecoration(
                  color: palette.slate,
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(
                    color: palette.slate.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.voidBlack,
                      offset: Offset(0, 3 * scale),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 20 * scale, right: 8 * scale),
                child: Text(
                  value,
                  style: TextStyle(
                    color: palette.twilight,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'EagleLake',
                    fontSize: 16 * scale,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              left: 2 * scale,
              child: Image.asset(
                iconPath,
                width: 45 * scale,
                height: 45 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );

    return expanded ? Expanded(child: pill) : pill;
  }
}
