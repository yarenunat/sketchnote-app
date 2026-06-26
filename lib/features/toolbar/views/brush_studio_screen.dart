import 'package:flutter/material.dart';

import '../../canvas/engine/brushes/brush_settings.dart';

/// Deep brush-editing screen, matching the reference "Brush Studio"
/// screenshot (image 3): a left rail of parameter categories (Stroke path,
/// Stabilization, Taper, Shape, Grain, Rendering, Wet Mix, Color dynamics,
/// Dynamics, Apple Pencil, Properties, Materials, About) with detail panels
/// and sliders, plus a live drawing-pad preview on the right.
///
/// Cursor TODO:
/// - This is a v2/stretch feature — ship with a handful of great built-in
///   presets first (see [BrushPresets]), then build this editor once the
///   core drawing experience is solid. Don't let this block v1.
/// - When built: left rail = category list, center = controls for the
///   selected category (sliders/toggles matching [BrushSettings] fields),
///   right = a small live `CanvasView`-like preview pad that redraws a
///   sample stroke in real time as parameters change.
/// - Persist edits back to a custom (user-modified) BrushSettings, never
///   silently mutate the shipped defaults — offer "Reset to default."
class BrushStudioScreen extends StatelessWidget {
  final BrushSettings initialBrush;

  const BrushStudioScreen({super.key, required this.initialBrush});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brush Studio')),
      body: const Placeholder(),
      // Cursor TODO: implement three-pane layout per the design notes above.
    );
  }
}
