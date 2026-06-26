import 'package:flutter/material.dart';

/// Bottom/side sheet listing brush categories and presets, matching the
/// reference "Brush Library" screenshot (image 4): a left rail of category
/// icons (Sketching, Inking, Drawing, Painting, ...) and a scrollable list
/// of named presets with a live stroke-shape preview thumbnail.
///
/// Cursor TODO:
/// - Generate each preset's preview thumbnail by actually rendering a short
///   sample stroke with that BrushSettings, not a static image, so it stays
///   accurate if the user edits the preset.
/// - Tap a preset => select it as active brush (canvasViewModelProvider).
/// - Provide a way to open [BrushStudioScreen] for deep editing (e.g. an
///   edit icon per preset, or a long-press).
class BrushLibrarySheet extends StatelessWidget {
  const BrushLibrarySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
    // Cursor TODO: implement two-pane (category rail + preset list) layout.
  }
}
