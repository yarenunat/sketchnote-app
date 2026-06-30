import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';

import '../../canvas/engine/brushes/brush_settings.dart';

/// Available page background templates.
enum PageBackgroundType {
  blank,
  lined,
  grid,
  dotted,
  millimeter,
}


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
    final byteData = ByteData.sublistView(blob);
    final points = <Offset>[];
    for (int i = 0; i < byteData.lengthInBytes; i += 16) {
      points.add(Offset(
        byteData.getFloat64(i, Endian.host),
        byteData.getFloat64(i + 8, Endian.host),
      ));
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
class NotebookPage {
  final String id;
  final int index;
  final List<StrokeData> strokes;
  final String? thumbnailPath;
  final PageBackgroundType backgroundType;

  const NotebookPage({
    required this.id,
    required this.index,
    this.strokes = const [],
    this.thumbnailPath,
    this.backgroundType = PageBackgroundType.blank,
  });

  NotebookPage copyWith({
    String? id,
    int? index,
    List<StrokeData>? strokes,
    String? thumbnailPath,
    PageBackgroundType? backgroundType,
  }) {
    return NotebookPage(
      id: id ?? this.id,
      index: index ?? this.index,
      strokes: strokes ?? this.strokes,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      backgroundType: backgroundType ?? this.backgroundType,
    );
  }
}

/// A notebook/journal: an ordered collection of pages plus metadata.
class Notebook {
  final String id;
  final String title;
  final List<NotebookPage> pages;
  final String coverAssetPath;
  final int coverColorValue;      // ARGB int for the cover background
  final DateTime? createdAt;
  final DateTime? modifiedAt;

  const Notebook({
    required this.id,
    required this.title,
    required this.pages,
    required this.coverAssetPath,
    this.coverColorValue = 0xFF8B1A1A,
    this.createdAt,
    this.modifiedAt,
  });

  Color get coverColor => Color(coverColorValue);

  int get pageCount => pages.length;

  Notebook copyWith({
    String? id,
    String? title,
    List<NotebookPage>? pages,
    String? coverAssetPath,
    int? coverColorValue,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Notebook(
      id: id ?? this.id,
      title: title ?? this.title,
      pages: pages ?? this.pages,
      coverAssetPath: coverAssetPath ?? this.coverAssetPath,
      coverColorValue: coverColorValue ?? this.coverColorValue,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
