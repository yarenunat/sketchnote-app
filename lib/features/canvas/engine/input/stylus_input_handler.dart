import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'input_point.dart';

/// Listens to raw pointer events on the canvas and converts them into a
/// stream of [InputPoint]s, applying palm rejection so an artist can rest
/// their hand on the screen while drawing with a stylus.
///
/// Cursor TODO — implementation plan:
/// 1. Wrap the canvas in a `Listener` (not `GestureDetector`) so we get raw
///    `PointerDownEvent` / `PointerMoveEvent` / `PointerUpEvent` /
///    `PointerCancelEvent` with full pressure/tilt/kind data, at native
///    sampling rate (don't let GestureDetector's gesture arena swallow or
///    delay events).
/// 2. Track multiple simultaneous pointers by `event.pointer` id in a map,
///    since palm + pencil can be down at once.
/// 3. Palm rejection heuristic (tune both, ship a "Palm rejection" setting
///    toggle since users have different preferences):
///    - If `kind == PointerDeviceKind.stylus` (or `invertedStylus` for
///      eraser-side), ALWAYS accept and start/continue a stroke.
///    - If `kind == PointerDeviceKind.touch`:
///        a. If a stylus pointer is currently active/down anywhere on this
///           page, ignore ALL simultaneous touch pointers (this is the main
///           palm-rejection case: hand resting while pencil draws).
///        b. If no stylus is active, touch can be allowed to draw (finger
///           drawing mode) — but expose a global "Touch to draw" toggle in
///           settings, since most pro users want touch reserved for
///           pan/zoom/scroll only and draw only with the pencil.
///        c. Optionally reject touches with `event.radiusMajor` /
///           `radiusMinor` above [AppConstants.palmRejectionMaxTouchRadius] —
///           a resting palm has a much larger contact area than a fingertip.
/// 4. Convert accepted events to [InputPoint] (map local position via
///    `RenderBox.globalToLocal`, normalize pressure, extract tilt).
/// 5. Expose a simple callback-based or Stream-based API to the canvas
///    controller — e.g. `onStrokeStart`, `onStrokePoint`, `onStrokeEnd`,
///    `onStrokeCancel` — so the canvas/viewmodel doesn't need to know
///    anything about raw PointerEvents.
/// 6. Handle `PointerCancelEvent` (e.g. OS gesture takes over, like a
///    system swipe) by canceling the in-progress stroke cleanly, not
///    committing a half-finished line.
class StylusInputHandler {
  // Cursor TODO: define constructor taking the required callbacks, and a
  // `bool allowFingerDrawing` setting injected from user preferences.

  void handlePointerDown(PointerDownEvent event) {
    throw UnimplementedError('Cursor: implement palm-rejection-aware pointer down handling.');
  }

  void handlePointerMove(PointerMoveEvent event) {
    throw UnimplementedError('Cursor: implement pointer move -> InputPoint conversion.');
  }

  void handlePointerUp(PointerUpEvent event) {
    throw UnimplementedError('Cursor: implement stroke finalization.');
  }

  void handlePointerCancel(PointerCancelEvent event) {
    throw UnimplementedError('Cursor: implement stroke cancellation.');
  }
}
