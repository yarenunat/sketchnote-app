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

  BrushSettings copyWith({
    String? id,
    String? name,
    String? shapeTexturePath,
    String? grainTexturePath,
    double? baseSize,
    double? pressureToSizeCurve,
    double? pressureToOpacityCurve,
    double? baseOpacity,
    double? spacing,
    double? scatter,
    double? rotationJitter,
    bool? followsStrokeDirection,
    double? taperStart,
    double? taperEnd,
    double? stabilization,
    BlendMode? blendMode,
  }) {
    return BrushSettings(
      id: id ?? this.id,
      name: name ?? this.name,
      shapeTexturePath: shapeTexturePath ?? this.shapeTexturePath,
      grainTexturePath: grainTexturePath ?? this.grainTexturePath,
      baseSize: baseSize ?? this.baseSize,
      pressureToSizeCurve: pressureToSizeCurve ?? this.pressureToSizeCurve,
      pressureToOpacityCurve: pressureToOpacityCurve ?? this.pressureToOpacityCurve,
      baseOpacity: baseOpacity ?? this.baseOpacity,
      spacing: spacing ?? this.spacing,
      scatter: scatter ?? this.scatter,
      rotationJitter: rotationJitter ?? this.rotationJitter,
      followsStrokeDirection: followsStrokeDirection ?? this.followsStrokeDirection,
      taperStart: taperStart ?? this.taperStart,
      taperEnd: taperEnd ?? this.taperEnd,
      stabilization: stabilization ?? this.stabilization,
      blendMode: blendMode ?? this.blendMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shapeTexturePath': shapeTexturePath,
      'grainTexturePath': grainTexturePath,
      'baseSize': baseSize,
      'pressureToSizeCurve': pressureToSizeCurve,
      'pressureToOpacityCurve': pressureToOpacityCurve,
      'baseOpacity': baseOpacity,
      'spacing': spacing,
      'scatter': scatter,
      'rotationJitter': rotationJitter,
      'followsStrokeDirection': followsStrokeDirection,
      'taperStart': taperStart,
      'taperEnd': taperEnd,
      'stabilization': stabilization,
      'blendMode': blendMode.index,
    };
  }

  factory BrushSettings.fromJson(Map<String, dynamic> json) {
    return BrushSettings(
      id: json['id'] as String,
      name: json['name'] as String,
      shapeTexturePath: json['shapeTexturePath'] as String?,
      grainTexturePath: json['grainTexturePath'] as String?,
      baseSize: (json['baseSize'] as num?)?.toDouble() ?? 6.0,
      pressureToSizeCurve: (json['pressureToSizeCurve'] as num?)?.toDouble() ?? 0.6,
      pressureToOpacityCurve: (json['pressureToOpacityCurve'] as num?)?.toDouble() ?? 0.3,
      baseOpacity: (json['baseOpacity'] as num?)?.toDouble() ?? 1.0,
      spacing: (json['spacing'] as num?)?.toDouble() ?? 0.1,
      scatter: (json['scatter'] as num?)?.toDouble() ?? 0.0,
      rotationJitter: (json['rotationJitter'] as num?)?.toDouble() ?? 0.0,
      followsStrokeDirection: json['followsStrokeDirection'] as bool? ?? false,
      taperStart: (json['taperStart'] as num?)?.toDouble() ?? 0.0,
      taperEnd: (json['taperEnd'] as num?)?.toDouble() ?? 0.0,
      stabilization: (json['stabilization'] as num?)?.toDouble() ?? 0.0,
      blendMode: json['blendMode'] != null 
          ? BlendMode.values[json['blendMode'] as int] 
          : BlendMode.srcOver,
    );
  }
}

/// A small built-in starter set, mirroring common categories from the
/// reference Brush Library screenshot (Sketching, Inking, Drawing, Painting,
/// Calligraphy, Airbrushing, Charcoals, ...).
class BrushPresets {
  BrushPresets._();

  static const BrushSettings technicalPen = BrushSettings(
    id: 'technical_pen',
    name: 'Technical Pen',
    baseSize: 3,
    pressureToSizeCurve: 0.1,
    pressureToOpacityCurve: 0.0,
    baseOpacity: 1.0,
    stabilization: 0.4,
    taperStart: 0.2,
    taperEnd: 0.2,
    blendMode: BlendMode.srcOver,
  );

  static const BrushSettings pencil = BrushSettings(
    id: 'pencil_hb',
    name: 'Pencil HB',
    baseSize: 5,
    pressureToSizeCurve: 0.6,
    pressureToOpacityCurve: 0.5,
    baseOpacity: 0.7,
    stabilization: 0.2,
    taperStart: 0.1,
    taperEnd: 0.1,
    blendMode: BlendMode.srcOver,
    grainTexturePath: 'assets/brush_textures/pencil_grain.png',
  );

  static const BrushSettings marker = BrushSettings(
    id: 'marker',
    name: 'Marker',
    baseSize: 22,
    pressureToSizeCurve: 0.05,  // Markers barely change width with pressure
    pressureToOpacityCurve: 0.0,
    baseOpacity: 0.45,
    stabilization: 0.1,
    blendMode: BlendMode.multiply,
  );

  static const BrushSettings watercolor = BrushSettings(
    id: 'watercolor',
    name: 'Watercolor',
    baseSize: 30,
    pressureToSizeCurve: 0.4,
    pressureToOpacityCurve: 0.6,
    baseOpacity: 0.12,
    scatter: 3.0,
    stabilization: 0.3,
    blendMode: BlendMode.srcOver,
  );

  static const BrushSettings softCharcoal = BrushSettings(
    id: 'soft_charcoal',
    name: 'Soft Charcoal',
    baseSize: 14,
    pressureToSizeCurve: 0.7,
    pressureToOpacityCurve: 0.6,
    baseOpacity: 0.8,
    scatter: 2.0,
    blendMode: BlendMode.srcOver,
    grainTexturePath: 'assets/brush_textures/charcoal_grain.png',
  );

  static const BrushSettings eraser = BrushSettings(
    id: 'eraser_soft',
    name: 'Soft Eraser',
    baseSize: 20,
    pressureToSizeCurve: 0.3,
    baseOpacity: 1.0,
    blendMode: BlendMode.clear,
  );

  static const List<BrushSettings> defaults = [
    technicalPen,
    pencil,
    marker,
    watercolor,
    softCharcoal,
  ];
}
