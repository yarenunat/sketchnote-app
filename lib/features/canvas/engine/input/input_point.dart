import 'dart:ui';

/// A single sampled point from a stylus/finger input, captured at native
/// event frequency (not yet smoothed/resampled).
///
/// Cursor TODO:
/// - Populate [pressure], [tiltX]/[tiltY] (or [orientation]/[altitude] on
///   iOS) from the raw `PointerEvent` in engine/input/stylus_input_handler.dart.
/// - On Android, `pressure` and `orientation`/`tilt` come from
///   `PointerEvent.pressure`, `PointerEvent.orientation`, `PointerEvent.tilt`.
/// - On iOS, Flutter surfaces Apple Pencil pressure via the same
///   `PointerEvent.pressure` (normalized 0–1) and tilt via `tilt`/`orientation`
///   as of recent Flutter engine versions — VERIFY against the Flutter version
///   pinned in pubspec.yaml, this API has evolved across releases.
class InputPoint {
  final Offset position;

  /// Normalized 0.0–1.0. 0 for devices that don't report pressure (finger).
  final double pressure;

  /// Stylus tilt in radians, if available. Null for finger input.
  final double? tiltX;
  final double? tiltY;

  /// Time since the stroke started, used for velocity-based width modulation
  /// and for smoothing/prediction.
  final Duration timestamp;

  /// Raw pointer kind: stylus, touch, mouse, trackpad — used by palm
  /// rejection and by brushes that behave differently per input kind.
  final PointerDeviceKind kind;

  const InputPoint({
    required this.position,
    required this.timestamp,
    required this.kind,
    this.pressure = 1.0,
    this.tiltX,
    this.tiltY,
  });
}

