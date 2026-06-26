import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/input/input_point.dart';
import '../engine/input/stylus_input_handler.dart';
import '../engine/stroke/stroke_builder.dart';
import '../viewmodels/canvas_viewmodel.dart';
import 'canvas_painter.dart';

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
      allowFingerDrawing: true, // Allowed for testing
    );
  }

  void _onStrokeStart(InputPoint point) {
    final state = ref.read(canvasViewModelProvider);
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
      ref.read(canvasViewModelProvider.notifier).addStroke(strokeResult);
      _activeStroke = null;
      // Rebuild handled by riverpod state update watching below
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
    final canvasState = ref.watch(canvasViewModelProvider);
    _bakeBackgroundIfNeeded(canvasState.committedStrokes);

    return InteractiveViewer(
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
    );
  }
}
