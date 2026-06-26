import 'package:flutter/material.dart';

/// Home/library screen: a horizontally-scrolling shelf (or grid) of
/// notebook covers, matching the reference "Journal" library screenshot
/// (image 1) — multiple covers with title + page count overlay, plus
/// a bottom bar with "delete / duplicate / new notebook" actions.
///
/// Cursor TODO:
/// - Implement a `PageView`/horizontal `ListView` of notebook cover cards
///   with a slight 3D perspective/scale-down effect on non-centered items
///   (matches the cover-flow-like look in the reference image).
/// - Tapping a notebook opens [NotebookPagerScreen] (image 2: open-book
///   page view with the page-turn/fan effect when swiping).
/// - "+" button creates a new notebook (prompt for cover style + page
///   template), via [LibraryViewModel].
/// - Long-press or the bottom-bar icons handle delete/duplicate/share.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SketchNote')),
      body: const Placeholder(),
      // Cursor TODO: implement real shelf/grid UI, wire to
      // libraryViewModelProvider for the list of notebooks.
    );
  }
}
