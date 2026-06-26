import 'dart:ui';

import '../../canvas/engine/brushes/brush_settings.dart';

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
import 'dart:convert';
import 'dart:typed_data';

class StrokeData {
  final String id;
  final BrushSettings brush;
  final Color color;
  final List<Offset> points;
  final Rect boundingBox;

  const StrokeData({
    required this.id,
    required this.brush,
    required this.color,
    required this.points,
    required this.boundingBox,
  });

  Uint8List pointsToBlob() {
    final floatList = Float64List(points.length * 2);
    for (int i = 0; i < points.length; i++) {
      floatList[i * 2] = points[i].dx;
      floatList[i * 2 + 1] = points[i].dy;
    }
    return floatList.buffer.asUint8List();
  }

  static List<Offset> blobToPoints(Uint8List blob) {
    // Depending on architecture, ByteData is safer but Float64List is faster.
    // For simplicity, we use ByteData to read float64 values sequentially.
    final byteData = ByteData.sublistView(blob);
    final points = <Offset>[];
    for (int i = 0; i < byteData.lengthInBytes; i += 16) {
      points.add(Offset(byteData.getFloat64(i, Endian.host), byteData.getFloat64(i + 8, Endian.host)));
    }
    return points;
  }

  String boundingBoxToJson() {
    return jsonEncode({
      'left': boundingBox.left,
      'top': boundingBox.top,
      'right': boundingBox.right,
      'bottom': boundingBox.bottom,
    });
  }

  static Rect boundingBoxFromJson(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return Rect.fromLTRB(
      (map['left'] as num).toDouble(),
      (map['top'] as num).toDouble(),
      (map['right'] as num).toDouble(),
      (map['bottom'] as num).toDouble(),
    );
  }
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
