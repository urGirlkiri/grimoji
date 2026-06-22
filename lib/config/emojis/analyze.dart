// ignore_for_file: avoid_print

/// Codegen script: reads index.dart, extracts all SVG paths from GameEmoji
/// entries, then parses each SVG file to produce a diagnostic report of all
/// tags, attributes, and path commands found across the emoji asset set.
/// 
library;

import 'dart:io';

void main() async {
  final File configFile = File('lib/config/emojis/index.dart');

  if (!await configFile.exists()) {
    print('ERROR: Could not find lib/config/emojis/index.dart');
    exit(1);
  }

  print('Reading emoji registry to gather SVG paths...');
  final String content = await configFile.readAsString();

  final RegExp emojiRegex = RegExp(r"GameEmoji\(\s*'([^']+)'");
  final matches = emojiRegex.allMatches(content).toList();

  if (matches.isEmpty) {
    print('CRITICAL ERROR: Found 0 SVG paths.');
    exit(1);
  }

  print('Found ${matches.length} SVGs to analyze. Scanning...\n');

  Set<String> allTags = {};
  Map<String, Set<String>> attributesByTag = {};
  Set<String> allPathCommands = {};
  int filesParsed = 0;
  int missingFiles = 0;

  for (final match in matches) {
    final String svgPath = match.group(1)!;
    final File svgFile = File(svgPath);

    if (await svgFile.exists()) {
      filesParsed++;
      final String svgContent = await svgFile.readAsString();

      final RegExp tagRegex = RegExp(r'<([a-zA-Z0-9_:-]+)([^>]*)>');
      final tagMatches = tagRegex.allMatches(svgContent);

      for (final tm in tagMatches) {
        final tag = tm.group(1)!;
        final attrString = tm.group(2) ?? '';

        allTags.add(tag);
        attributesByTag.putIfAbsent(tag, () => {});

        final RegExp attrRegex = RegExp(r'([a-zA-Z0-9_:-]+)\s*=');
        final attrMatches = attrRegex.allMatches(attrString);
        for (final am in attrMatches) {
          attributesByTag[tag]!.add(am.group(1)!);
        }

        if (tag == 'path') {
          final RegExp dRegex = RegExp(r'''d\s*=\s*["']([^"']+)["']''');
          final dMatch = dRegex.firstMatch(attrString);
          if (dMatch != null) {
            final dString = dMatch.group(1)!;

            final RegExp cmdRegex = RegExp(r'[a-zA-Z]');
            final cmdMatches = cmdRegex.allMatches(dString);
            for (final cm in cmdMatches) {
              allPathCommands.add(cm.group(0)!);
            }
          }
        }
      }
    } else {
      missingFiles++;
    }
  }

  print('=========================================');
  print('          SVG DIAGNOSTIC REPORT          ');
  print('=========================================');
  print('Files Parsed: $filesParsed');
  if (missingFiles > 0) print('Missing Files: $missingFiles');
  print('-----------------------------------------');

  print('\n[1] ALL SVG TAGS DISCOVERED:');
  final sortedTags = allTags.toList()..sort();
  for (var tag in sortedTags) {
    print('  - <$tag>');
  }

  print('\n[2] ATTRIBUTES USED PER TAG:');
  for (var tag in sortedTags) {
    final attrs = attributesByTag[tag]!.toList()..sort();
    if (attrs.isNotEmpty) {
      print('  <$tag> uses: ${attrs.join(', ')}');
    }
  }

  print('\n[3] PATH COMMANDS DISCOVERED IN <path d="...">:');
  final sortedCommands = allPathCommands.toList()..sort();
  print('  Commands: ${sortedCommands.join(', ')}');
  print('=========================================');
}
