import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notebook/models/notebook_models.dart';
import '../engine/brushes/brush_settings.dart';

/// Holds the editable state for the page currently open in [CanvasView]:
/// committed strokes, undo/redo stacks, active tool/brush/color, zoom/pan.
///
/// Cursor TODO:
/// - Implement undo/redo as two stacks of immutable page snapshots OR
///   command objects (`AddStrokeCommand`, `EraseCommand`, ...) — command
///   pattern scales better once layers exist, snapshot is simpler for v1.
///   Cap stack size at [AppConstants.maxUndoStackSize].
/// - Persist to the storage service (Drift/sqlite) on a debounce after
///   each completed stroke, not on every frame.
/// - Expose derived providers: `currentBrushProvider`, `currentColorProvider`,
///   `canUndoProvider`, `canRedoProvider`, etc., so toolbar widgets can
///   `watch` narrowly and avoid rebuilding the whole canvas on tool changes.
class CanvasState {
  final NotebookPage page;
  final BrushSettings activeBrush;
  final bool isErasing;

  const CanvasState({
    required this.page,
    required this.activeBrush,
    this.isErasing = false,
  });
}

class CanvasViewModel extends Notifier<CanvasState> {
  @override
  CanvasState build() {
    throw UnimplementedError('Cursor: load the requested page from storage and seed initial state.');
  }

  void selectBrush(BrushSettings brush) {
    throw UnimplementedError('Cursor: implement.');
  }

  void undo() {
    throw UnimplementedError('Cursor: implement.');
  }

  void redo() {
    throw UnimplementedError('Cursor: implement.');
  }
}

final canvasViewModelProvider =
    NotifierProvider<CanvasViewModel, CanvasState>(CanvasViewModel.new);
