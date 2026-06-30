import 'dart:ui';

import '../engine/stroke/stroke_builder.dart';

/// Represents a single drawing layer on a page.
///
/// Layers are drawn in order (index 0 = bottom, last = top).
/// Each layer has its own stroke list, opacity, visibility, and blend mode.
class LayerState {
  final String id;
  final String name;
  final List<StrokeResult> strokes;
  final double opacity;          // 0.0 – 1.0
  final bool isVisible;
  final BlendMode blendMode;
  final bool isLocked;

  const LayerState({
    required this.id,
    required this.name,
    this.strokes = const [],
    this.opacity = 1.0,
    this.isVisible = true,
    this.blendMode = BlendMode.srcOver,
    this.isLocked = false,
  });

  LayerState copyWith({
    String? id,
    String? name,
    List<StrokeResult>? strokes,
    double? opacity,
    bool? isVisible,
    BlendMode? blendMode,
    bool? isLocked,
  }) {
    return LayerState(
      id: id ?? this.id,
      name: name ?? this.name,
      strokes: strokes ?? this.strokes,
      opacity: opacity ?? this.opacity,
      isVisible: isVisible ?? this.isVisible,
      blendMode: blendMode ?? this.blendMode,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  /// Returns a new LayerState with the given stroke appended.
  LayerState addStroke(StrokeResult stroke) {
    return copyWith(strokes: [...strokes, stroke]);
  }

  /// Returns a new LayerState with the last N strokes removed (for undo).
  LayerState removeLastStroke() {
    if (strokes.isEmpty) return this;
    return copyWith(strokes: strokes.sublist(0, strokes.length - 1));
  }
}

/// Factories for creating default layers.
class LayerFactory {
  LayerFactory._();

  static LayerState createDefault({int index = 0}) {
    return LayerState(
      id: 'layer_${DateTime.now().microsecondsSinceEpoch}_$index',
      name: index == 0 ? 'Background' : 'Layer ${index + 1}',
      strokes: const [],
      opacity: 1.0,
      isVisible: true,
    );
  }
}
