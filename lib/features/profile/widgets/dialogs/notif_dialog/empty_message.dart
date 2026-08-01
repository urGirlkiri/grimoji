import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/utils/context_data.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No secret messages yet",
        textAlign: TextAlign.center,
        style: context.theme.textTheme.bodyLarge!.copyWith(
          color: palette.midnight,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
