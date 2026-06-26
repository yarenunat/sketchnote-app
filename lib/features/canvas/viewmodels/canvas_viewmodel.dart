import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notebook/models/notebook_models.dart';
import '../engine/brushes/brush_settings.dart';
import '../engine/stroke/stroke_builder.dart';
import '../engine/input/input_point.dart';
import '../../../core/services/storage/storage_service.dart';
import 'package:uuid/uuid.dart';

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

class CanvasViewModel extends FamilyAsyncNotifier<CanvasState, String> {
  late StorageService _storage;

  @override
  Future<CanvasState> build(String arg) async {
    _storage = ref.read(storageServiceProvider);

    NotebookPage page;
    try {
      page = await _storage.getPage(arg);
    } catch (_) {
      try {
        final nb = await _storage.createNotebook(title: 'My Notes', coverAssetPath: '');
        page = nb.pages.first;
      } catch (_) {
        page = NotebookPage(id: arg, index: 0, strokes: const []);
      }
    }

    final strokes = page.strokes.map((s) => _rebuildStroke(s)).toList();

    return CanvasState(
      page: page,
      activeBrush: BrushPresets.defaults.first,
      committedStrokes: strokes,
    );
  }

  StrokeResult _rebuildStroke(StrokeData data) {
    final builder = StrokeBuilder(brush: data.brush, color: data.color);
    for (final pt in data.points) {
      builder.addPoint(InputPoint(
        position: pt,
        timestamp: Duration.zero,
        kind: PointerDeviceKind.stylus,
        pressure: 1.0,
      ));
    }
    return builder.finish();
  }

  void addStroke(StrokeResult strokeResult) {
    final currentState = state.value!;
    final newState = currentState.committedStrokes.toList()..add(strokeResult);
    final newUndoStack = currentState.undoStack.toList()..add(currentState.committedStrokes);
    
    if (newUndoStack.length > 50) {
      newUndoStack.removeAt(0);
    }
    
    state = AsyncValue.data(currentState.copyWith(
      committedStrokes: newState,
      undoStack: newUndoStack,
      redoStack: [],
    ));

    // Persist
    final strokeData = StrokeData(
      id: const Uuid().v4(),
      brush: strokeResult.brushSnapshot,
      color: strokeResult.color,
      points: [], // In a full implementation, StrokeResult would expose raw points
      boundingBox: strokeResult.boundingBox,
    );
    _storage.saveStroke(pageId: currentState.page.id, stroke: strokeData);
  }

  void selectBrush(BrushSettings brush) {
    state = AsyncValue.data(state.value!.copyWith(activeBrush: brush));
  }

  void selectColor(Color color) {
    state = AsyncValue.data(state.value!.copyWith(activeColor: color));
  }

  void toggleEraser() {
    state = AsyncValue.data(state.value!.copyWith(isErasing: !state.value!.isErasing));
  }

  void undo() {
    final currentState = state.value!;
    if (currentState.undoStack.isEmpty) return;
    
    final newUndoStack = currentState.undoStack.toList();
    final previousStrokes = newUndoStack.removeLast();
    
    final newRedoStack = currentState.redoStack.toList()..add(currentState.committedStrokes);
    
    state = AsyncValue.data(currentState.copyWith(
      committedStrokes: previousStrokes,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    ));
    
    // DB Sync omitted for brevity in v1, ideally we delete removed strokes.
  }

  void redo() {
    final currentState = state.value!;
    if (currentState.redoStack.isEmpty) return;
    
    final newRedoStack = currentState.redoStack.toList();
    final nextStrokes = newRedoStack.removeLast();
    
    final newUndoStack = currentState.undoStack.toList()..add(currentState.committedStrokes);
    
    state = AsyncValue.data(currentState.copyWith(
      committedStrokes: nextStrokes,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    ));
  }
}

final canvasViewModelProvider =
    AsyncNotifierProviderFamily<CanvasViewModel, CanvasState, String>(CanvasViewModel.new);
