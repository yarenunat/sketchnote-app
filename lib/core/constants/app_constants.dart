/// App-wide constant values.
///
/// Cursor TODO: tune these after testing on real devices (iPad + Galaxy Tab).
class AppConstants {
  AppConstants._();

  // --- Canvas / performance ---

  /// Target page size in logical points at 1x, before pixel ratio scaling.
  /// A4-ish ratio, matches the "Journal" page look from the reference design.
  static const double defaultPageWidth = 1024;
  static const double defaultPageHeight = 1366;

  /// Minimum distance (in px) between two raw input points before we add a
  /// new point to the active stroke. Prevents oversampling on high-frequency
  /// stylus input while keeping curves smooth.
  static const double minPointDistance = 1.5;

  /// Max stroke points buffered before we flush to a finalized Path, to cap
  /// memory growth on very long strokes.
  static const int maxBufferedPoints = 4000;

  // --- Input ---

  /// Palm rejection: minimum contact "size"/pointer kind heuristics live in
  /// engine/input — this is just the fallback touch-radius threshold.
  static const double palmRejectionMaxTouchRadius = 40.0;

  // --- Undo/redo ---
  static const int maxUndoStackSize = 100;
}
