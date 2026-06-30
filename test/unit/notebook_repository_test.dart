import 'package:flutter/painting.dart' show Offset, Rect;
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';

import 'package:sketchnote/features/notebook/models/notebook_models.dart';
import 'package:sketchnote/features/canvas/engine/brushes/brush_settings.dart';

void main() {
  group('NotebookPage', () {
    test('has blank background type by default', () {
      const page = NotebookPage(id: 'p1', index: 0);
      expect(page.backgroundType, PageBackgroundType.blank);
    });

    test('copyWith changes only specified fields', () {
      const page = NotebookPage(id: 'p1', index: 0);
      final updated = page.copyWith(backgroundType: PageBackgroundType.lined);

      expect(updated.id, 'p1');
      expect(updated.index, 0);
      expect(updated.backgroundType, PageBackgroundType.lined);
    });

    test('has empty strokes by default', () {
      const page = NotebookPage(id: 'p1', index: 0);
      expect(page.strokes, isEmpty);
    });
  });

  group('Notebook', () {
    test('pageCount returns length of pages list', () {
      final nb = Notebook(
        id: 'nb1',
        title: 'Test',
        pages: const [
          NotebookPage(id: 'p1', index: 0),
          NotebookPage(id: 'p2', index: 1),
        ],
        coverAssetPath: '',
      );
      expect(nb.pageCount, 2);
    });

    test('coverColor parses correctly from ARGB int', () {
      final nb = Notebook(
        id: 'nb1',
        title: 'Test',
        pages: const [],
        coverAssetPath: '',
        coverColorValue: 0xFF8B1A1A,
      );
      expect(nb.coverColor.toARGB32(), 0xFF8B1A1A);
    });

    test('copyWith preserves unmodified fields', () {
      final original = Notebook(
        id: 'nb1',
        title: 'My Journal',
        pages: const [],
        coverAssetPath: 'cover.png',
        coverColorValue: 0xFF1B3A6B,
      );

      final copy = original.copyWith(title: 'Updated Title');

      expect(copy.id, 'nb1');
      expect(copy.title, 'Updated Title');
      expect(copy.coverAssetPath, 'cover.png');
      expect(copy.coverColorValue, 0xFF1B3A6B);
    });
  });

  group('StrokeData serialization', () {
    test('points round-trip through blob encoding', () {
      const offsets = [
        Offset(10.5, 20.3),
        Offset(100.0, 200.0),
        Offset(0.0, 0.0),
      ];

      final stroke = StrokeData(
        id: 's1',
        brush: BrushPresets.technicalPen,
        color: const Color(0xFF000000),
        points: offsets,
        boundingBox: const Rect.fromLTRB(0, 0, 100, 200),
      );

      final blob = stroke.pointsToBlob();
      final decoded = StrokeData.blobToPoints(blob);

      expect(decoded.length, offsets.length);
      for (int i = 0; i < offsets.length; i++) {
        expect(decoded[i].dx, closeTo(offsets[i].dx, 0.001));
        expect(decoded[i].dy, closeTo(offsets[i].dy, 0.001));
      }
    });

    test('bounding box serializes and deserializes correctly', () {
      const box = Rect.fromLTRB(10.0, 20.0, 110.0, 220.0);
      final stroke = StrokeData(
        id: 's2',
        brush: BrushPresets.pencil,
        color: const Color(0xFF333333),
        points: const [],
        boundingBox: box,
      );

      final json = stroke.boundingBoxToJson();
      final decoded = StrokeData.boundingBoxFromJson(json);

      expect(decoded.left, closeTo(box.left, 0.001));
      expect(decoded.top, closeTo(box.top, 0.001));
      expect(decoded.right, closeTo(box.right, 0.001));
      expect(decoded.bottom, closeTo(box.bottom, 0.001));
    });
  });

  group('BrushSettings', () {
    test('copyWith only changes specified fields', () {
      const original = BrushPresets.pencil;
      final modified = original.copyWith(baseSize: 20.0);

      expect(modified.id, original.id);
      expect(modified.name, original.name);
      expect(modified.baseSize, 20.0);
      expect(modified.baseOpacity, original.baseOpacity);
    });

    test('toJson / fromJson round-trip', () {
      const original = BrushPresets.marker;
      final json = original.toJson();
      final restored = BrushSettings.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.baseSize, original.baseSize);
      expect(restored.baseOpacity, original.baseOpacity);
      expect(restored.blendMode, original.blendMode);
    });

    test('all default presets have non-empty ids', () {
      for (final brush in BrushPresets.defaults) {
        expect(brush.id, isNotEmpty);
      }
    });
  });

  group('PageBackgroundType', () {
    test('all values are available', () {
      expect(PageBackgroundType.values.length, 5);
      expect(PageBackgroundType.values, contains(PageBackgroundType.blank));
      expect(PageBackgroundType.values, contains(PageBackgroundType.lined));
      expect(PageBackgroundType.values, contains(PageBackgroundType.grid));
      expect(PageBackgroundType.values, contains(PageBackgroundType.dotted));
      expect(PageBackgroundType.values,
          contains(PageBackgroundType.millimeter));
    });
  });
}
