import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/app/palette.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> pumpScrollDialog(
    WidgetTester tester, {
    required Widget child,
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      Provider(
        create: (_) => const Palette(),
        child: MaterialApp(
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            overscroll: true,
            scrollbars: true,
          ),
          home: Scaffold(
            body: Center(child: ScrollDialog(child: child)),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('short content fills the viewport without scrolling', (
    tester,
  ) async {
    await pumpScrollDialog(
      tester,
      child: const Center(child: SizedBox(height: 100, child: Text('Short'))),
    );

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

    expect(scrollable.position.maxScrollExtent, 0);
    expect(tester.getSize(find.text('Short')).height, lessThan(400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tall content scrolls within the dialog without overflow', (
    tester,
  ) async {
    await pumpScrollDialog(
      tester,
      child: const SizedBox(height: 800, child: Text('Tall')),
    );

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

    expect(scrollable.position.maxScrollExtent, greaterThan(0));
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pump();
    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared behavior suppresses scrollbars and overscroll visuals', (
    tester,
  ) async {
    await pumpScrollDialog(
      tester,
      child: const SizedBox(height: 800, child: Text('Tall')),
    );

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 200));
    await tester.pump();

    expect(find.byType(Scrollbar), findsNothing);
    expect(find.byType(GlowingOverscrollIndicator), findsNothing);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
