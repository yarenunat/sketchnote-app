import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notebook/models/notebook_models.dart';
import '../engine/brushes/brush_settings.dart';
import '../engine/stroke/stroke_builder.dart';
import '../engine/input/input_point.dart';
import '../models/layer_model.dart';
import '../../../core/services/storage/storage_service.dart';
import '../../../core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class CanvasState {
  final NotebookPage page;
  final BrushSettings activeBrush;
  final Color activeColor;
  final double activeOpacity;           // 0.0 – 1.0 brush opacity modifier
  final double activeThickness;         // multiplier on brush.baseSize
  final bool isErasing;
  final List<LayerState> layers;
  final int activeLayerIndex;
  final bool isLayerPanelOpen;
  final List<Color> recentColors;

  // Undo/redo stacks — each entry is a snapshot of [layers]
  final List<List<LayerState>> undoStack;
  final List<List<LayerState>> redoStack;

  const CanvasState({
    required this.page,
    required this.activeBrush,
    this.activeColor = const Color(0xFF1A1614),
    this.activeOpacity = 1.0,
    this.activeThickness = 1.0,
    this.isErasing = false,
    this.layers = const [],
    this.activeLayerIndex = 0,
    this.isLayerPanelOpen = false,
    this.recentColors = const [],
    this.undoStack = const [],
    this.redoStack = const [],
  });

  LayerState get activeLayer => layers.isNotEmpty
      ? layers[activeLayerIndex.clamp(0, layers.length - 1)]
      : LayerFactory.createDefault();

  /// All strokes across all visible layers (for display purposes).
  List<StrokeResult> get allVisibleStrokes => layers
      .where((l) => l.isVisible)
      .expand((l) => l.strokes)
      .toList();

  CanvasState copyWith({
    NotebookPage? page,
    BrushSettings? activeBrush,
    Color? activeColor,
    double? activeOpacity,
    double? activeThickness,
    bool? isErasing,
    List<LayerState>? layers,
    int? activeLayerIndex,
    bool? isLayerPanelOpen,
    List<Color>? recentColors,
    List<List<LayerState>>? undoStack,
    List<List<LayerState>>? redoStack,
  }) {
    return CanvasState(
      page: page ?? this.page,
      activeBrush: activeBrush ?? this.activeBrush,
      activeColor: activeColor ?? this.activeColor,
      activeOpacity: activeOpacity ?? this.activeOpacity,
      activeThickness: activeThickness ?? this.activeThickness,
      isErasing: isErasing ?? this.isErasing,
      layers: layers ?? this.layers,
      activeLayerIndex: activeLayerIndex ?? this.activeLayerIndex,
      isLayerPanelOpen: isLayerPanelOpen ?? this.isLayerPanelOpen,
      recentColors: recentColors ?? this.recentColors,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ViewModel
// ─────────────────────────────────────────────────────────────────────────────

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
        final nb = await _storage.createNotebook(
            title: 'My Notes', coverAssetPath: '');
        page = nb.pages.first;
      } catch (_) {
        page = NotebookPage(id: arg, index: 0, strokes: const []);
      }
    }

    // Rebuild strokes into the default layer
    final strokes = page.strokes.map((s) => _rebuildStroke(s)).toList();
    final defaultLayer = LayerFactory.createDefault(index: 0)
        .copyWith(strokes: strokes);

    return CanvasState(
      page: page,
      activeBrush: BrushPresets.defaults.first,
      layers: [defaultLayer],
      activeLayerIndex: 0,
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

  // ── Stroke management ──────────────────────────────────────────────────

  void addStroke(StrokeResult strokeResult) {
    final currentState = state.value!;
    if (currentState.layers.isEmpty) return;

    // Push to undo stack
    final newUndoStack = [...currentState.undoStack, currentState.layers];
    if (newUndoStack.length > AppConstants.maxUndoStackSize) {
      newUndoStack.removeAt(0);
    }

    final newLayers = List<LayerState>.from(currentState.layers);
    final layerIdx = currentState.activeLayerIndex.clamp(0, newLayers.length - 1);
    newLayers[layerIdx] = newLayers[layerIdx].addStroke(strokeResult);

    state = AsyncValue.data(currentState.copyWith(
      layers: newLayers,
      undoStack: newUndoStack,
      redoStack: [], // Clear redo on new stroke
    ));

    // Persist (fire-and-forget)
    final strokeData = StrokeData(
      id: const Uuid().v4(),
      brush: strokeResult.brushSnapshot,
      color: strokeResult.color,
      points: [],
      boundingBox: strokeResult.boundingBox,
    );
    _storage.saveStroke(
        pageId: currentState.page.id, stroke: strokeData);
  }

  void undo() {
    final currentState = state.value!;
    if (currentState.undoStack.isEmpty) return;

    final newUndoStack = [...currentState.undoStack];
    final previousLayers = newUndoStack.removeLast();
    final newRedoStack = [...currentState.redoStack, currentState.layers];

    state = AsyncValue.data(currentState.copyWith(
      layers: previousLayers,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    ));
  }

  void redo() {
    final currentState = state.value!;
    if (currentState.redoStack.isEmpty) return;

    final newRedoStack = [...currentState.redoStack];
    final nextLayers = newRedoStack.removeLast();
    final newUndoStack = [...currentState.undoStack, currentState.layers];

    state = AsyncValue.data(currentState.copyWith(
      layers: nextLayers,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    ));
  }

  // ── Brush & color ─────────────────────────────────────────────────────

  void selectBrush(BrushSettings brush) {
    state = AsyncValue.data(state.value!.copyWith(
      activeBrush: brush,
      isErasing: false,
    ));
  }

  void selectColor(Color color) {
    final current = state.value!;
    // Prepend to recent colors, max 10
    final recent = [color, ...current.recentColors.where((c) => c.toARGB32() != color.toARGB32())]
        .take(10)
        .toList();
    state = AsyncValue.data(current.copyWith(
      activeColor: color,
      isErasing: false,
      recentColors: recent,
    ));
  }

  void setOpacity(double opacity) {
    state = AsyncValue.data(state.value!.copyWith(
      activeOpacity: opacity.clamp(0.05, 1.0),
    ));
  }

  void setThickness(double thickness) {
    state = AsyncValue.data(state.value!.copyWith(
      activeThickness: thickness.clamp(0.1, 5.0),
    ));
  }

  void toggleEraser() {
    final current = state.value!;
    state = AsyncValue.data(current.copyWith(
      isErasing: !current.isErasing,
    ));
  }

  void activateEraser() {
    state = AsyncValue.data(state.value!.copyWith(isErasing: true));
  }

  // ── Layer management ──────────────────────────────────────────────────

  void addLayer() {
    final current = state.value!;
    if (current.layers.length >= 10) return; // Max 10 layers

    final newLayer = LayerFactory.createDefault(index: current.layers.length);
    final newLayers = [...current.layers, newLayer];

    state = AsyncValue.data(current.copyWith(
      layers: newLayers,
      activeLayerIndex: newLayers.length - 1,
    ));
  }

  void deleteLayer(String layerId) {
    final current = state.value!;
    if (current.layers.length <= 1) return; // Can't delete the last layer

    final newLayers = current.layers.where((l) => l.id != layerId).toList();
    final newIdx = (current.activeLayerIndex).clamp(0, newLayers.length - 1);

    state = AsyncValue.data(current.copyWith(
      layers: newLayers,
      activeLayerIndex: newIdx,
    ));
  }

  void selectLayer(int index) {
    final current = state.value!;
    final clamped = index.clamp(0, current.layers.length - 1);
    state = AsyncValue.data(current.copyWith(activeLayerIndex: clamped));
  }

  void reorderLayer(int oldIndex, int newIndex) {
    final current = state.value!;
    final layers = List<LayerState>.from(current.layers);

    final item = layers.removeAt(oldIndex);
    final insertIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    layers.insert(insertIndex, item);

    int newActiveIdx = current.activeLayerIndex;
    if (current.activeLayerIndex == oldIndex) {
      newActiveIdx = insertIndex;
    } else if (current.activeLayerIndex > oldIndex && current.activeLayerIndex <= insertIndex) {
      newActiveIdx--;
    } else if (current.activeLayerIndex < oldIndex && current.activeLayerIndex >= insertIndex) {
      newActiveIdx++;
    }

    state = AsyncValue.data(current.copyWith(
      layers: layers,
      activeLayerIndex: newActiveIdx,
    ));
  }

  void toggleLayerVisibility(String layerId) {
    final current = state.value!;
    final newLayers = current.layers.map((l) {
      if (l.id == layerId) return l.copyWith(isVisible: !l.isVisible);
      return l;
    }).toList();
    state = AsyncValue.data(current.copyWith(layers: newLayers));
  }

  void setLayerOpacity(String layerId, double opacity) {
    final current = state.value!;
    final newLayers = current.layers.map((l) {
      if (l.id == layerId) return l.copyWith(opacity: opacity.clamp(0.0, 1.0));
      return l;
    }).toList();
    state = AsyncValue.data(current.copyWith(layers: newLayers));
  }

  void renameLayer(String layerId, String name) {
    final current = state.value!;
    final newLayers = current.layers.map((l) {
      if (l.id == layerId) return l.copyWith(name: name);
      return l;
    }).toList();
    state = AsyncValue.data(current.copyWith(layers: newLayers));
  }

  void toggleLayerPanel() {
    final current = state.value!;
    state = AsyncValue.data(
        current.copyWith(isLayerPanelOpen: !current.isLayerPanelOpen));
  }

  void flattenLayers() {
    final current = state.value!;
    if (current.layers.length <= 1) return;

    final allStrokes = current.allVisibleStrokes;
    final flatLayer = LayerFactory.createDefault(index: 0)
        .copyWith(name: 'Merged Layer', strokes: allStrokes);

    state = AsyncValue.data(current.copyWith(
      layers: [flatLayer],
      activeLayerIndex: 0,
      undoStack: [...current.undoStack, current.layers],
    ));
  }
}

final canvasViewModelProvider =
    AsyncNotifierProviderFamily<CanvasViewModel, CanvasState, String>(
        CanvasViewModel.new);
