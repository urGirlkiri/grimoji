import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';

void main() {
  group('Emojis Test', () {
    test('No two emojis should share the same visual', () {
      final visualToEmojis = <String, List<String>>{};
      for (var emoji in Emojis.all) {
        visualToEmojis.putIfAbsent(emoji.visual, () => []).add(emoji.svg);
      }
      final duplicates = visualToEmojis.entries
          .where((e) => e.value.length > 1)
          .toList();

      final duplicateInfo = duplicates
          .map((e) => '${e.key}:\n  ${e.value.join("\n  ")}')
          .join('\n');

      expect(
        duplicates,
        isEmpty,
        reason: 'Duplicate visual emojis found:\n$duplicateInfo',
      );
    });

    test('All SVGs and Lotties mentioned in emojis.dart MUST exist', () {
      final file = File('lib/config/emojis/index.dart');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'Could not find lib/config/emojis/index.dart',
      );

      final fileContent = file.readAsStringSync();

      final svgRegex = RegExp(r"'([^']+\.svg)'");
      final lottieRegex = RegExp(r"'([^']+\.json)'");

      final svgPaths = svgRegex
          .allMatches(fileContent)
          .map((m) => m.group(1)!)
          .toSet();
      final lottiePaths = lottieRegex
          .allMatches(fileContent)
          .map((m) => m.group(1)!)
          .toSet();

      expect(
        svgPaths,
        isNotEmpty,
        reason: 'Regex failed to find any SVGs in emojis.dart',
      );
      expect(
        lottiePaths,
        isNotEmpty,
        reason: 'Regex failed to find any Lotties in emojis.dart',
      );

      for (final path in svgPaths) {
        final svgFile = File(path);
        expect(
          svgFile.existsSync(),
          isTrue,
          reason: 'CRITICAL: Broken SVG link found in emojis.dart -> $path',
        );
      }

      for (final path in lottiePaths) {
        final lottieFile = File(path);
        expect(
          lottieFile.existsSync(),
          isTrue,
          reason: 'CRITICAL: Broken Lottie link found in emojis.dart -> $path',
        );
      }
    });
  });
}
