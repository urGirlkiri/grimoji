import 'package:flutter/material.dart';

@immutable
class Layout {
  final double emojiSize;
  final double cacheSize;

  const Layout({
    required this.emojiSize,
    required this.cacheSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Layout &&
          runtimeType == other.runtimeType &&
          emojiSize == other.emojiSize &&
          cacheSize == other.cacheSize;

  @override
  int get hashCode => Object.hash(emojiSize, cacheSize);
}