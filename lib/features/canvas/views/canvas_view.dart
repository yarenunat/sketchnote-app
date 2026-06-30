import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/input/input_point.dart';
import '../engine/input/stylus_input_handler.dart';
import '../engine/stroke/stroke_builder.dart';
import '../engine/brushes/brush_settings.dart';
import '../models/layer_model.dart';
import '../viewmodels/canvas_viewmodel.dart';
import '../viewmodels/collage_controller.dart';
import '../widgets/layer_panel_widget.dart';
import '../widgets/draggable_image_widget.dart';
import 'canvas_painter.dart';
import '../../toolbar/views/toolbar_view.dart';

/// The main drawing canvas screen.
///
/// Architecture:
///  ┌─────────────────────────────────────────────────────┐
///  │ Stack (full screen)                                  │
///  │  ├─ Page background (color/texture)                  │
///  │  ├─ InteractiveViewer (2-finger pan/zoom only)       │
///  │  │    └─ Listener (stylus+1-finger draws strokes)    │
///  │  │         └─ Layer stack (CustomPaint per layer)    │
///  │  ├─ Collage layer (DraggableImageWidgets)            │
///  │  ├─ Layer panel (slides in from right)               │
///  │  ├─ Top controls (close, undo, redo)                 │
///  │  └─ Bottom toolbar (colors + tools + layers btn)     │
///  └─────────────────────────────────────────────────────┘
///
/// KEY DESIGN DECISION — zoom/draw conflict:
///   We use [InteractiveViewer.panEnabled] = false and track pointer count
///   ourselves. When 2+ fingers are detected, we disable drawing and let
///   InteractiveViewer handle pan/zoom. With 1 finger/stylus, we draw.
class CanvasView extends ConsumerStatefulWidget {
  final String pageId;
  const CanvasView({super.key, required this.pageId});

  @override
  ConsumerState<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends ConsumerState<CanvasView>
    with SingleTickerProviderStateMixin {
  late StylusInputHandler _inputHandler;
  StrokeBuilder? _activeStroke;

  // Cached baked backgrounds per layer index
  final Map<int, ui.Picture?> _cachedBackgrounds = {};
  final Map<int, int> _lastBakedCounts = {};

  // Pointer count for zoom/draw switching
  int _activePointerCount = 0;
  bool get _isZooming => _activePointerCount >= 2;

  // InteractiveViewer transform controller
  final TransformationController _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _inputHandler = StylusInputHandler(
      onStrokeStart: _onStrokeStart,
      onStrokePoint: _onStrokePoint,
      onStrokeEnd: _onStrokeEnd,
      onStrokeCancel: _onStrokeCancel,
      allowFingerDrawing: true,
    );
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  // ── Stroke lifecycle ─────────────────────────────────────────────────────

  void _onStrokeStart(InputPoint point) {
    if (_isZooming) return;
    final stateAsync = ref.read(canvasViewModelProvider(widget.pageId));
    if (!stateAsync.hasValue) return;
    final state = stateAsync.value!;

    // Apply opacity/thickness modifiers to a temporary brush
    final modifiedBrush = state.isErasing
        ? BrushPresets.eraser
        : state.activeBrush.copyWith(
            baseSize: state.activeBrush.baseSize * state.activeThickness,
            baseOpacity: state.activeBrush.baseOpacity * state.activeOpacity,
          );

    _activeStroke = StrokeBuilder(
      brush: modifiedBrush,
      color: state.isErasing ? const ui.Color(0xFFFFFFFF) : state.activeColor,
    );
    _activeStroke!.addPoint(point);
    setState(() {});
  }

  void _onStrokePoint(InputPoint point) {
    if (_isZooming) return;
    _activeStroke?.addPoint(point);
    setState(() {});
  }

  void _onStrokeEnd(InputPoint point) {
    if (_activeStroke != null) {
      if (!_isZooming) {
        _activeStroke!.addPoint(point);
        final result = _activeStroke!.finish();
        ref.read(canvasViewModelProvider(widget.pageId).notifier).addStroke(result);
      }
      _activeStroke = null;
    }
  }

  void _onStrokeCancel() {
    _activeStroke = null;
    setState(() {});
  }

  // ── Baked background cache ───────────────────────────────────────────────

  ui.Picture? _bakeLayerIfNeeded(LayerState layer, int layerIdx) {
    final lastCount = _lastBakedCounts[layerIdx] ?? -1;
    if (lastCount == layer.strokes.length && _cachedBackgrounds.containsKey(layerIdx)) {
      return _cachedBackgrounds[layerIdx];
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final stroke in layer.strokes) {
      _paintStroke(canvas, stroke);
    }

    final picture = recorder.endRecording();
    _cachedBackgrounds[layerIdx] = picture;
    _lastBakedCounts[layerIdx] = layer.strokes.length;
    return picture;
  }

  void _paintStroke(Canvas canvas, dynamic stroke) {
    final paint = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill
      ..blendMode = stroke.brushSnapshot.blendMode;
    canvas.drawPath(stroke.path, paint);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final canvasStateAsync = ref.watch(canvasViewModelProvider(widget.pageId));
    final collageItems = ref.watch(collageControllerProvider(widget.pageId));
    final collageCtrl = ref.read(collageControllerProvider(widget.pageId).notifier);

    return canvasStateAsync.when(
      data: (canvasState) {
        // Deselect collage items when canvas is tapped
        return GestureDetector(
          onTap: () => collageCtrl.deselectAll(),
          child: Stack(
            children: [
              // ── White Drawing Canvas with InteractiveViewer ──────────
              Positioned.fill(
                child: RepaintBoundary(
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    minScale: 0.25,
                    maxScale: 8.0,
                    // Disable built-in pan so we can control it manually
                    panEnabled: _isZooming,
                    scaleEnabled: _isZooming,
                    child: Listener(
                      onPointerDown: (e) {
                        setState(() => _activePointerCount++);
                        if (!_isZooming) _inputHandler.handlePointerDown(e);
                      },
                      onPointerMove: (e) {
                        if (!_isZooming) _inputHandler.handlePointerMove(e);
                      },
                      onPointerUp: (e) {
                        if (!_isZooming) _inputHandler.handlePointerUp(e);
                        setState(() => _activePointerCount = (_activePointerCount - 1).clamp(0, 10));
                      },
                      onPointerCancel: (e) {
                        _inputHandler.handlePointerCancel(e);
                        setState(() => _activePointerCount = (_activePointerCount - 1).clamp(0, 10));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          children: [
                            // ── All layers (baked) ──────────────────────
                            ...canvasState.layers.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final layer = entry.value;
                              if (!layer.isVisible) return const SizedBox.shrink();
                              final baked = _bakeLayerIfNeeded(layer, idx);
                              return RepaintBoundary(
                                child: Opacity(
                                  opacity: layer.opacity,
                                  child: CustomPaint(
                                    painter: CanvasPainter(
                                      backgroundPicture: baked,
                                      activeStroke: idx == canvasState.activeLayerIndex
                                          ? _activeStroke
                                          : null,
                                    ),
                                    size: Size.infinite,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Collage layer (above drawings) ───────────────────────
              if (collageItems.isNotEmpty)
                Positioned.fill(
                  child: Stack(
                    children: collageItems.map((item) {
                      final isSelected = collageCtrl.selectedItemId == item.id;
                      return DraggableImageWidget(
                        key: ValueKey(item.id),
                        item: item,
                        isSelected: isSelected,
                        onSelect: () => collageCtrl.selectItem(item.id),
                        onUpdate: ({position, scale, rotation}) =>
                            collageCtrl.updateTransform(
                          itemId: item.id,
                          position: position,
                          scale: scale,
                          rotation: rotation,
                        ),
                        onDelete: () => collageCtrl.deleteItem(item.id),
                        onBringToFront: () => collageCtrl.bringToFront(item.id),
                      );
                    }).toList(),
                  ),
                ),

              // ── Layer panel (slides from right) ──────────────────────
              if (canvasState.isLayerPanelOpen)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: LayerPanelWidget(pageId: widget.pageId),
                  ),
                ),

              // ── Top Controls (Back, Undo, Redo) ──────────────────────
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: Row(
                    children: [
                      _buildTopButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      _buildTopButton(
                        icon: Icons.undo,
                        onTap: canvasState.undoStack.isNotEmpty
                            ? () => ref
                                .read(canvasViewModelProvider(widget.pageId).notifier)
                                .undo()
                            : null,
                      ),
                      const SizedBox(width: 8),
                      _buildTopButton(
                        icon: Icons.redo,
                        onTap: canvasState.redoStack.isNotEmpty
                            ? () => ref
                                .read(canvasViewModelProvider(widget.pageId).notifier)
                                .redo()
                            : null,
                      ),
                      const SizedBox(width: 8),
                      // Zoom reset
                      _buildTopButton(
                        icon: Icons.zoom_out_map,
                        onTap: () => _transformController.value = Matrix4.identity(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom Toolbar ────────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: ToolbarView(pageId: widget.pageId),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (e, st) => Center(
        child: Text('Error loading canvas: $e'),
      ),
    );
  }

  Widget _buildTopButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(230),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.black87 : Colors.black26,
          size: 18,
        ),
      ),
    );
  }
}
