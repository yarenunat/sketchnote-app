import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/input/input_point.dart';
import '../engine/input/stylus_input_handler.dart';
import '../engine/stroke/stroke_builder.dart';
import '../viewmodels/canvas_viewmodel.dart';
import 'canvas_painter.dart';
import '../../toolbar/views/toolbar_view.dart';

class CanvasView extends ConsumerStatefulWidget {
  final String pageId;

  const CanvasView({super.key, required this.pageId});

  @override
  ConsumerState<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends ConsumerState<CanvasView> {
  late StylusInputHandler _inputHandler;
  StrokeBuilder? _activeStroke;
  ui.Picture? _cachedBackground;

  int _lastCommittedCount = -1;

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

  void _onStrokeStart(InputPoint point) {
    final stateAsync = ref.read(canvasViewModelProvider(widget.pageId));
    if (!stateAsync.hasValue) return;
    final state = stateAsync.value!;

    _activeStroke = StrokeBuilder(
      brush: state.activeBrush,
      color: state.activeColor,
    );
    _activeStroke!.addPoint(point);
    setState(() {});
  }

  void _onStrokePoint(InputPoint point) {
    _activeStroke?.addPoint(point);
    setState(() {});
  }

  void _onStrokeEnd(InputPoint point) {
    if (_activeStroke != null) {
      _activeStroke!.addPoint(point);
      final strokeResult = _activeStroke!.finish();
      ref
          .read(canvasViewModelProvider(widget.pageId).notifier)
          .addStroke(strokeResult);
      _activeStroke = null;
    }
  }

  void _onStrokeCancel() {
    _activeStroke = null;
    setState(() {});
  }

  void _bakeBackgroundIfNeeded(List<StrokeResult> strokes) {
    if (_lastCommittedCount == strokes.length) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..style = PaintingStyle.fill
        ..blendMode = stroke.brushSnapshot.blendMode;
      canvas.drawPath(stroke.path, paint);
    }

    _cachedBackground = recorder.endRecording();
    _lastCommittedCount = strokes.length;
  }

  @override
  Widget build(BuildContext context) {
    final canvasStateAsync = ref.watch(canvasViewModelProvider(widget.pageId));

    return canvasStateAsync.when(
      data: (canvasState) {
        _bakeBackgroundIfNeeded(canvasState.committedStrokes);

        return Stack(
          children: [
            // ── White Drawing Canvas ──────────────────────────
            Positioned.fill(
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                child: Listener(
                  onPointerDown: _inputHandler.handlePointerDown,
                  onPointerMove: _inputHandler.handlePointerMove,
                  onPointerUp: _inputHandler.handlePointerUp,
                  onPointerCancel: _inputHandler.handlePointerCancel,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: CustomPaint(
                      painter: CanvasPainter(
                        backgroundPicture: _cachedBackground,
                        activeStroke: _activeStroke,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),

            // ── Top Controls (X, Undo, Redo) — Paper style ───
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Close / Back button
                  _buildTopButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  // Undo button
                  _buildTopButton(
                    icon: Icons.undo,
                    onTap: canvasState.undoStack.isNotEmpty
                        ? () => ref
                            .read(canvasViewModelProvider(widget.pageId).notifier)
                            .undo()
                        : null,
                  ),
                  const SizedBox(width: 8),
                  // Redo button
                  _buildTopButton(
                    icon: Icons.redo,
                    onTap: canvasState.redoStack.isNotEmpty
                        ? () => ref
                            .read(canvasViewModelProvider(widget.pageId).notifier)
                            .redo()
                        : null,
                  ),
                ],
              ),
            ),

            // ── Bottom Toolbar (colors + tools) ───────────────
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ToolbarView(pageId: widget.pageId),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading page: $e')),
    );
  }

  Widget _buildTopButton(
      {required IconData icon, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.black87 : Colors.black26,
          size: 20,
        ),
      ),
    );
  }
}
