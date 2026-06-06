import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class InventoryCard extends StatelessWidget {
  const InventoryCard({
    super.key,
    required this.context,
    required this.name,
    required this.iconPath,
    required this.count,
  });

  final BuildContext context;
  final String name;
  final String iconPath;
  final int count;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = count <= 0;

    return Container(
      decoration: BoxDecoration(
        color:context.palette.twilight.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmpty ? context.palette.twilight : context.palette.twilight.withValues(alpha: 200),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Opacity(
                opacity: isEmpty ? 0.3 : 1.0,
                child: EmojiWidget.svg(path: iconPath, size: 45* context.globalScale),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color:context.palette.mist,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isEmpty
                    ? context.palette.twilight
                    : context.palette.slate,
                shape: BoxShape.circle,
                boxShadow: isEmpty
                    ? []
                    : [
                        BoxShadow(
                          color: context.palette.voidBlack,
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
              ),
              child: Text(
                count.toString(),
                style: context.theme.textTheme.labelMedium?.copyWith(
                  color: context.palette.moonlight,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
