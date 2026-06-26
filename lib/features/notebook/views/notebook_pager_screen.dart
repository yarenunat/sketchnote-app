import 'package:flutter/material.dart';

/// Open-notebook page navigator, matching the reference screenshot (image 2):
/// a "fanned pages" view when idle/swiping, settling into a flat
/// [CanvasView] for the centered page when the user starts drawing.
///
/// Cursor TODO:
/// - Implement the page-turn / fan visual using a `PageView` with a custom
///   transition builder (scale + slight rotation + drop shadow per offset
///   page, similar to a cover-flow), OR a simpler swipe-to-flip skeuomorphic
///   page-curl effect if time allows — start simple (plain PageView,
///   crossfade) and layer on the fancier visual later.
/// - Each page in the PageView renders a thumbnail until it becomes the
///   active page, then swaps to a live interactive [CanvasView].
/// - Bottom bar: delete page / export / add page (matches reference icons).
class NotebookPagerScreen extends StatelessWidget {
  final String notebookId;

  const NotebookPagerScreen({super.key, required this.notebookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Placeholder(),
      // Cursor TODO: implement PageView + page-turn transition + bottom bar.
    );
  }
}
