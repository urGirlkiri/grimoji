// ignore_for_file: avoid_print
import 'dart:io';

/// Codegen script: reads index.dart, collects all GameEmoji variable names,
/// then writes a `static final List<GameEmoji> all = [...]` block into the
/// Emojis class. 
/// 
void main() async {
  final File indexFile = File('lib/config/emojis/index.dart');

  if (!await indexFile.exists()) {
    print('ERROR: Could not find lib/config/emojis/index.dart');
    exit(1);
  }

  print('Reading emoji registry...');
  final String content = await indexFile.readAsString();

  final RegExp emojiRegex = RegExp(
    r'static\s+(?:const|final)\s+GameEmoji\s+(\w+)\s*=\s*GameEmoji\s*\(',
  );

  final names = emojiRegex
      .allMatches(content)
      .map((m) => m.group(1)!)
      .toList();

  if (names.isEmpty) {
    print('CRITICAL ERROR: Found 0 GameEmoji entries. Aborting.');
    exit(1);
  }

  print('Found ${names.length} emojis. Generating Emojis.all...');

  final allBlock = StringBuffer();
  allBlock.writeln('\n  static final List<GameEmoji> all = [');
  for (final name in names) {
    allBlock.writeln('    $name,');
  }
  allBlock.write('  ];');

  final existingAllRegex = RegExp(
    r'\n\s*static final List<GameEmoji> all = \[[\s\S]*?\];',
  );

  String updated;
  if (existingAllRegex.hasMatch(content)) {
    updated = content.replaceFirst(existingAllRegex, allBlock.toString());
    print('Replaced existing Emojis.all block.');
  } else {
    final closingBrace = content.lastIndexOf('}');
    if (closingBrace == -1) {
      print('ERROR: Could not find closing brace of Emojis class.');
      exit(1);
    }
    updated = '${content.substring(0, closingBrace)}$allBlock\n}\n';
    print('Appended new Emojis.all block.');
  }

  await indexFile.writeAsString(updated);
  print('SUCCESS: index.dart updated with ${names.length} entries in Emojis.all.');
}
