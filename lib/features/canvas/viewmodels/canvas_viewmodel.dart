import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notebook/models/notebook_models.dart';
import '../engine/brushes/brush_settings.dart';
import '../engine/stroke/stroke_builder.dart';

class CanvasState {
  final NotebookPage page;
  final BrushSettings activeBrush;
  final Color activeColor;
  final bool isErasing;
  final List<StrokeResult> committedStrokes;
  final List<List<StrokeResult>> undoStack;
  final List<List<StrokeResult>> redoStack;

  const CanvasState({
    required this.page,
    required this.activeBrush,
    this.activeColor = const Color(0xFF000000),
    this.isErasing = false,
    this.committedStrokes = const [],
    this.undoStack = const [],
    this.redoStack = const [],
  });

  CanvasState copyWith({
    NotebookPage? page,
    BrushSettings? activeBrush,
    Color? activeColor,
    bool? isErasing,
    List<StrokeResult>? committedStrokes,
    List<List<StrokeResult>>? undoStack,
    List<List<StrokeResult>>? redoStack,
  }) {
    return CanvasState(
      page: page ?? this.page,
      activeBrush: activeBrush ?? this.activeBrush,
      activeColor: activeColor ?? this.activeColor,
      isErasing: isErasing ?? this.isErasing,
      committedStrokes: committedStrokes ?? this.committedStrokes,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

class CanvasViewModel extends Notifier<CanvasState> {
  @override
  CanvasState build() {
    return CanvasState(
      page: const NotebookPage(id: 'dummy', index: 0),
      activeBrush: BrushPresets.defaults.first,
    );
  }

  void addStroke(StrokeResult stroke) {
    final newState = state.committedStrokes.toList()..add(stroke);
    final newUndoStack = state.undoStack.toList()..add(state.committedStrokes);
    
    // Cap undo stack size
    if (newUndoStack.length > 50) {
      newUndoStack.removeAt(0);
    }
    
    state = state.copyWith(
      committedStrokes: newState,
      undoStack: newUndoStack,
      redoStack: [], // clear redo stack on new action
    );
  }

  void selectBrush(BrushSettings brush) {
    state = state.copyWith(activeBrush: brush);
  }

  void selectColor(Color color) {
    state = state.copyWith(activeColor: color);
  }

  void toggleEraser() {
    state = state.copyWith(isErasing: !state.isErasing);
  }

  void undo() {
    if (state.undoStack.isEmpty) return;
    
    final newUndoStack = state.undoStack.toList();
    final previousStrokes = newUndoStack.removeLast();
    
    final newRedoStack = state.redoStack.toList()..add(state.committedStrokes);
    
    state = state.copyWith(
      committedStrokes: previousStrokes,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    
    final newRedoStack = state.redoStack.toList();
    final nextStrokes = newRedoStack.removeLast();
    
    final newUndoStack = state.undoStack.toList()..add(state.committedStrokes);
    
    state = state.copyWith(
      committedStrokes: nextStrokes,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }
}

final canvasViewModelProvider =
    NotifierProvider<CanvasViewModel, CanvasState>(CanvasViewModel.new);
