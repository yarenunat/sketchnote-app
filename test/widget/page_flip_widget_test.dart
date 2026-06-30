import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sketchnote/shared/widgets/page_flip_widget.dart';

void main() {
  /// A helper that builds the PageFlipWidget inside a MaterialApp
  /// with the given dimensions.
  Widget buildSubject({
    required Widget currentPage,
    required Widget nextPage,
    Widget? previousPage,
    required VoidCallback onFlipForward,
    VoidCallback? onFlipBackward,
    bool allowBackwardFlip = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 600,
          child: PageFlipWidget(
            currentPage: currentPage,
            nextPage: nextPage,
            previousPage: previousPage,
            onFlipForward: onFlipForward,
            onFlipBackward: onFlipBackward,
            allowBackwardFlip: allowBackwardFlip,
          ),
        ),
      ),
    );
  }

  group('PageFlipWidget', () {
    testWidgets('renders current page without errors', (tester) async {
      await tester.pumpWidget(buildSubject(
        currentPage: const ColoredBox(
          color: Colors.white,
          child: Center(child: Text('Page 1')),
        ),
        nextPage: const ColoredBox(
          color: Colors.white,
          child: Center(child: Text('Page 2')),
        ),
        onFlipForward: () {},
      ));

      expect(find.text('Page 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows next page when flip is triggered', (tester) async {
      bool flipped = false;

      await tester.pumpWidget(buildSubject(
        currentPage: const ColoredBox(
          color: Colors.white,
          child: Center(child: Text('Page 1')),
        ),
        nextPage: const ColoredBox(
          color: Colors.blue,
          child: Center(child: Text('Page 2')),
        ),
        onFlipForward: () => flipped = true,
      ));

      // The next page is rendered in the stack (as the background layer)
      // and is visible before the flip completes.
      await tester.pump();

      // Trigger a pan starting from the right edge (x=380 for 400px wide widget)
      final gesture = await tester.startGesture(const Offset(380, 300));
      await tester.pump();

      // Drag >50% of width to trigger forward flip
      await gesture.moveBy(const Offset(-250, 0));
      await tester.pump();

      await gesture.up();
      // Let the spring animation complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(flipped, isTrue);
    });

    testWidgets('snaps back when drag is less than 50%', (tester) async {
      bool flipped = false;

      await tester.pumpWidget(buildSubject(
        currentPage: const ColoredBox(
          color: Colors.white,
          child: Center(child: Text('Page 1')),
        ),
        nextPage: const ColoredBox(
          color: Colors.blue,
          child: Center(child: Text('Page 2')),
        ),
        onFlipForward: () => flipped = true,
      ));

      // Drag only 30% — should snap back
      final gesture = await tester.startGesture(const Offset(380, 300));
      await tester.pump();

      await gesture.moveBy(const Offset(-100, 0)); // ~25% of 400px
      await tester.pump();

      await gesture.up();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Flip should NOT have been called
      expect(flipped, isFalse);
    });

    testWidgets('ignores pan that does not start at the edge', (tester) async {
      bool flipped = false;

      await tester.pumpWidget(buildSubject(
        currentPage: const ColoredBox(
          color: Colors.white,
          child: Center(child: Text('Page 1')),
        ),
        nextPage: const ColoredBox(
          color: Colors.blue,
          child: Center(child: Text('Page 2')),
        ),
        onFlipForward: () => flipped = true,
      ));

      // Start pan from the center — should not trigger flip
      final gesture = await tester.startGesture(const Offset(200, 300));
      await tester.pump();
      await gesture.moveBy(const Offset(-300, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(flipped, isFalse);
    });

    testWidgets('does not show previous page when allowBackwardFlip=false',
        (tester) async {
      bool backFlipped = false;

      await tester.pumpWidget(buildSubject(
        currentPage: const ColoredBox(
          color: Colors.white,
          child: Center(child: Text('Page 2')),
        ),
        nextPage: const ColoredBox(
          color: Colors.blue,
          child: Center(child: Text('Page 3')),
        ),
        previousPage: const ColoredBox(
          color: Colors.green,
          child: Center(child: Text('Page 1')),
        ),
        onFlipForward: () {},
        onFlipBackward: () => backFlipped = true,
        allowBackwardFlip: false, // explicitly disabled
      ));

      // Drag from left edge trying to go backward
      final gesture = await tester.startGesture(const Offset(20, 300));
      await tester.pump();
      await gesture.moveBy(const Offset(250, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(backFlipped, isFalse);
    });

    testWidgets('renders without overflow on narrow screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: PageFlipWidget(
                currentPage: Container(color: Colors.white),
                nextPage: Container(color: Colors.grey.shade200),
                onFlipForward: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
