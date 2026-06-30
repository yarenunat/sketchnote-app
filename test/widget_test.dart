// Smoke test for the SketchNote app.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sketchnote/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SketchNoteApp()),
    );
    // Library screen should appear – look for its FAB or any widget
    expect(tester.takeException(), isNull);
  });
}
