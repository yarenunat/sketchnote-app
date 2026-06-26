import 'package:flutter/gestures.dart';

import 'input_point.dart';

/// Listens to raw pointer events on the canvas and converts them into a
/// stream of [InputPoint]s, applying palm rejection so an artist can rest
/// their hand on the screen while drawing with a stylus.
///
class StylusInputHandler {
  final void Function(InputPoint) onStrokeStart;
  final void Function(InputPoint) onStrokePoint;
  final void Function(InputPoint) onStrokeEnd;
  final void Function() onStrokeCancel;
  final bool allowFingerDrawing;

  StylusInputHandler({
    required this.onStrokeStart,
    required this.onStrokePoint,
    required this.onStrokeEnd,
    required this.onStrokeCancel,
    this.allowFingerDrawing = false,
  });

  int? _activeStrokePointerId;
  int _activeStylusPointersCount = 0;

  bool _isStylus(PointerDeviceKind kind) =>
      kind == PointerDeviceKind.stylus || kind == PointerDeviceKind.invertedStylus;

  void handlePointerDown(PointerDownEvent event) {
    if (_isStylus(event.kind)) {
      _activeStylusPointersCount++;
    }

    if (_activeStrokePointerId != null) return; // Already drawing

    if (_isStylus(event.kind) || (allowFingerDrawing && _activeStylusPointersCount == 0)) {
      _activeStrokePointerId = event.pointer;
      onStrokeStart(_createInputPoint(event));
    }
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (event.pointer == _activeStrokePointerId) {
      onStrokePoint(_createInputPoint(event));
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    if (_isStylus(event.kind)) {
      _activeStylusPointersCount--;
      if (_activeStylusPointersCount < 0) _activeStylusPointersCount = 0;
    }

    if (event.pointer == _activeStrokePointerId) {
      _activeStrokePointerId = null;
      onStrokeEnd(_createInputPoint(event));
    }
  }

  void handlePointerCancel(PointerCancelEvent event) {
    if (_isStylus(event.kind)) {
      _activeStylusPointersCount--;
      if (_activeStylusPointersCount < 0) _activeStylusPointersCount = 0;
    }

    if (event.pointer == _activeStrokePointerId) {
      _activeStrokePointerId = null;
      onStrokeCancel();
    }
  }

  InputPoint _createInputPoint(PointerEvent event) {
    return InputPoint(
      position: event.localPosition,
      timestamp: event.timeStamp,
      kind: event.kind,
      pressure: event.pressure,
      tiltX: event.tilt,
      tiltY: event.orientation,
    );
  }
}
