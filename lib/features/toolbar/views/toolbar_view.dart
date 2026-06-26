import 'package:flutter/material.dart';

/// The drawing toolbar: brush picker, color picker, undo/redo, eraser,
/// lasso/select tool, layers panel trigger, page navigation.
///
/// Cursor TODO:
/// - Match the reference app's floating, semi-transparent, icon-only style
///   (see image 4's top bar: Gallery / wrench / magic-wand / pen-icon /
///   share / brush / pencil / eraser / layers / color-dot).
/// - Keep it usable one-handed on a tablet held in landscape — likely a
///   slim floating bar pinned to one edge with a user-configurable side
///   (left/right-handed mode toggle in settings).
/// - Tapping the brush icon opens [BrushLibrarySheet]; long-press opens
///   [BrushStudioScreen] for editing that brush (matches reference image 4
///   tap vs. image 3 deep-edit).
class ToolbarView extends StatelessWidget {
  const ToolbarView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
    // Cursor TODO: implement real layout, wire to canvasViewModelProvider.
  }
}
