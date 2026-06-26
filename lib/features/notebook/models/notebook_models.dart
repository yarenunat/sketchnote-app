import 'dart:ui';

import '../engine/brushes/brush_settings.dart';

/// A single finalized stroke on a page, as stored in the page model
/// (distinct from the engine's transient `StrokeResult` used only while
/// the line is fresh — though in practice this likely just wraps it).
///
/// Cursor TODO:
/// - Decide whether to persist raw input points (for future re-editing /
///   resolution-independent re-render) or only the baked vector Path.
///   Recommendation: persist raw points + brush id + color; bake the Path
///   lazily/on-demand, so storage stays small and brushes can be
///   retroactively improved without corrupting old drawings.
/// - Add serialization for the chosen on-disk format (see export/ and
///   storage/ services) — likely a compact binary or msgpack-like encoding
///   for point lists, not verbose JSON, since a page can have tens of
///   thousands of points.
class StrokeData {
  final String id;
  final BrushSettings brush;
  final Color color;
  final List<Offset> points; // simplified placeholder; real version should
  // store pressure/tilt per point too — replace with List<InputPoint> or a
  // dedicated lightweight struct to avoid pulling input/UI types into the
  // persistence model.
  final Rect boundingBox;

  const StrokeData({
    required this.id,
    required this.brush,
    required this.color,
    required this.points,
    required this.boundingBox,
  });
}

/// A single page within a notebook.
///
/// Cursor TODO:
/// - Add page background type: blank / lined / grid / dotted (the reference
///   "Journal" screenshots show a blank handwriting page — start there,
///   expand to templates).
/// - Add layers: List<PageLayer> where each layer has its own stroke list,
///   opacity, blend mode, visibility, lock state — professional users will
///   expect at least basic layering.
/// - Track a `thumbnailPath` that's regenerated after edits, for fast
///   library/grid rendering without re-rendering full pages.
class NotebookPage {
  final String id;
  final int index;
  final List<StrokeData> strokes;
  final String? thumbnailPath;

  const NotebookPage({
    required this.id,
    required this.index,
    this.strokes = const [],
    this.thumbnailPath,
  });
}

/// A notebook/journal: an ordered collection of pages plus metadata, as
/// seen in the reference "Journal" cover screenshots.
///
/// Cursor TODO:
/// - Add cover customization (color/pattern/image) matching the visual
///   variety shown in the library screenshot (image 1).
/// - Add `createdAt`/`modifiedAt` for sorting in the library grid.
/// - Add tags/folders for organization once the library has more than a
///   handful of notebooks.
class Notebook {
  final String id;
  final String title;
  final List<NotebookPage> pages;
  final String coverAssetPath;

  const Notebook({
    required this.id,
    required this.title,
    required this.pages,
    required this.coverAssetPath,
  });

  int get pageCount => pages.length;
}
