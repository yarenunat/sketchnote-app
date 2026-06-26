import 'dart:ui';

/// Defines the behavior of a brush, independent of any specific stroke.
/// This is the data model that the "Brush Studio" UI (see reference image 3)
/// will read from and write to.
///
/// Cursor TODO:
/// - This is intentionally similar in spirit to Procreate's brush model
///   (shape source, grain/texture, scatter, rotation/azimuth, jitter,
///   pressure curves) — re-implement the subset needed for v1, not all of it.
/// - Add `copyWith` for immutability-friendly editing in the Brush Studio UI.
/// - Add JSON serialization (toJson/fromJson) so brush presets can be saved
///   to disk and exported/shared as a `.brushpreset` file later.
class BrushSettings {
  final String id;
  final String name;

  /// Path to the shape/grain texture asset used for the stroke stamp,
  /// e.g. 'assets/brush_textures/charcoal_01.png'. Null = procedural round.
  final String? shapeTexturePath;
  final String? grainTexturePath;

  /// Base width in logical px at pressure = 1.0 and zoom = 1.0.
  final double baseSize;

  /// 0.0 (no effect) – 1.0 (full effect): how much pressure affects width.
  final double pressureToSizeCurve;

  /// 0.0 (no effect) – 1.0 (full effect): how much pressure affects opacity.
  final double pressureToOpacityCurve;

  /// Base opacity 0.0–1.0 before pressure modulation.
  final double baseOpacity;

  /// Stamp spacing along the stroke path, as a fraction of brush size
  /// (smaller = smoother but more expensive).
  final double spacing;

  /// Randomized per-stamp scatter offset, in px.
  final double scatter;

  /// Randomized per-stamp rotation jitter, in radians.
  final double rotationJitter;

  /// Whether stamp rotation follows the stroke direction (azimuth-following,
  /// like a calligraphy nib) vs. staying fixed.
  final bool followsStrokeDirection;

  /// Tapering at stroke start/end, 0.0 (no taper) – 1.0 (full point taper).
  final double taperStart;
  final double taperEnd;

  /// Stroke smoothing/stabilization strength, 0.0–1.0 — higher trades a bit
  /// of latency for steadier lines (useful for inking/lettering brushes).
  final double stabilization;

  final BlendMode blendMode;

  const BrushSettings({
    required this.id,
    required this.name,
    this.shapeTexturePath,
    this.grainTexturePath,
    this.baseSize = 6.0,
    this.pressureToSizeCurve = 0.6,
    this.pressureToOpacityCurve = 0.3,
    this.baseOpacity = 1.0,
    this.spacing = 0.1,
    this.scatter = 0.0,
    this.rotationJitter = 0.0,
    this.followsStrokeDirection = false,
    this.taperStart = 0.0,
    this.taperEnd = 0.0,
    this.stabilization = 0.0,
    this.blendMode = BlendMode.srcOver,
  });

  // Cursor TODO: implement copyWith, toJson, fromJson.
}

/// A small built-in starter set, mirroring common categories from the
/// reference Brush Library screenshot (Sketching, Inking, Drawing, Painting,
/// Calligraphy, Airbrushing, Charcoals, ...).
///
/// Cursor TODO: replace these placeholder presets with real tuned values,
/// and load actual texture assets once designed.
class BrushPresets {
  BrushPresets._();

  static const BrushSettings technicalPen = BrushSettings(
    id: 'technical_pen',
    name: 'Technical Pen',
    baseSize: 3,
    pressureToSizeCurve: 0.1,
    pressureToOpacityCurve: 0.0,
    stabilization: 0.4,
  );

  static const BrushSettings pencil = BrushSettings(
    id: 'pencil_hb',
    name: 'Pencil HB',
    baseSize: 4,
    pressureToSizeCurve: 0.5,
    pressureToOpacityCurve: 0.5,
    grainTexturePath: 'assets/brush_textures/pencil_grain.png',
  );

  static const BrushSettings softCharcoal = BrushSettings(
    id: 'soft_charcoal',
    name: 'Soft Charcoal',
    baseSize: 14,
    pressureToSizeCurve: 0.7,
    pressureToOpacityCurve: 0.6,
    scatter: 2.0,
    grainTexturePath: 'assets/brush_textures/charcoal_grain.png',
  );

  static const BrushSettings eraser = BrushSettings(
    id: 'eraser_soft',
    name: 'Soft Eraser',
    baseSize: 18,
    blendMode: BlendMode.clear,
  );

  static const List<BrushSettings> defaults = [
    technicalPen,
    pencil,
    softCharcoal,
  ];
}
