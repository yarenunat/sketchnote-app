import 'dart:ui';

/// A single sampled point from a stylus/finger input, captured at native
/// event frequency (not yet smoothed/resampled).
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

