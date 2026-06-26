import '../../../features/notebook/models/notebook_models.dart';

/// High-level persistence API used by viewmodels. Hides whether data
/// actually lives in Drift, flat files, or a hybrid — viewmodels should
/// never import Drift types directly.
///
/// Cursor TODO: implement against app_database.dart once that schema is
/// generated. Keep all methods async and batched (e.g. saving a finished
/// stroke should not block the UI thread or stall mid-drawing).
import 'dart:convert';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/canvas/engine/brushes/brush_settings.dart';
import 'app_database.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return DriftStorageService(AppDatabase());
});

abstract class StorageService {
  Future<List<Notebook>> getAllNotebooks();
  Future<Notebook> createNotebook({required String title, required String coverAssetPath});
  Future<void> deleteNotebook(String id);
  Future<NotebookPage> getPage(String pageId);
  Future<void> saveStroke({required String pageId, required StrokeData stroke});
  Future<void> deleteStroke({required String pageId, required String strokeId});
}

class DriftStorageService implements StorageService {
  final AppDatabase _db;

  DriftStorageService(this._db);

  @override
  Future<List<Notebook>> getAllNotebooks() async {
    final notebookEntities = await _db.select(_db.notebooks).get();
    final List<Notebook> result = [];
    
    for (final entity in notebookEntities) {
      final pageEntities = await (_db.select(_db.pages)..where((tbl) => tbl.notebookId.equals(entity.id))).get();
      
      final pages = <NotebookPage>[];
      for (final p in pageEntities) {
        final strokeEntities = await (_db.select(_db.strokes)..where((tbl) => tbl.pageId.equals(p.id))).get();
        
        final strokes = strokeEntities.map((s) => StrokeData(
          id: s.id,
          brush: BrushSettings.fromJson(jsonDecode(s.brushSettingsJson) as Map<String, dynamic>),
          color: Color(s.colorValue),
          points: StrokeData.blobToPoints(s.geometryBlob),
          boundingBox: StrokeData.boundingBoxFromJson(s.boundingBoxJson),
        )).toList();

        pages.add(NotebookPage(
          id: p.id,
          index: p.pageIndex,
          strokes: strokes,
          thumbnailPath: p.thumbnailPath,
        ));
      }

      result.add(Notebook(
        id: entity.id,
        title: entity.title,
        pages: pages,
        coverAssetPath: entity.coverAssetPath,
      ));
    }
    return result;
  }

  @override
  Future<Notebook> createNotebook({required String title, required String coverAssetPath}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final notebook = NotebookEntity(
      id: id,
      title: title,
      coverAssetPath: coverAssetPath,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      sortIndex: 0,
    );
    await _db.into(_db.notebooks).insert(notebook);
    
    final pageId = '${id}_page_1';
    await _db.into(_db.pages).insert(PageEntity(
      id: pageId,
      notebookId: id,
      pageIndex: 0,
      backgroundType: null,
      thumbnailPath: null,
    ));

    return Notebook(
      id: id,
      title: title,
      pages: [NotebookPage(id: pageId, index: 0, strokes: const [])],
      coverAssetPath: coverAssetPath,
    );
  }

  @override
  Future<void> deleteNotebook(String id) async {
    await (_db.delete(_db.notebooks)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<NotebookPage> getPage(String pageId) async {
    final pageEntity = await (_db.select(_db.pages)..where((tbl) => tbl.id.equals(pageId))).getSingle();
    final strokeEntities = await (_db.select(_db.strokes)..where((tbl) => tbl.pageId.equals(pageId))).get();
    
    final strokes = strokeEntities.map((s) => StrokeData(
      id: s.id,
      brush: BrushSettings.fromJson(jsonDecode(s.brushSettingsJson) as Map<String, dynamic>),
      color: Color(s.colorValue),
      points: StrokeData.blobToPoints(s.geometryBlob),
      boundingBox: StrokeData.boundingBoxFromJson(s.boundingBoxJson),
    )).toList();

    return NotebookPage(
      id: pageEntity.id,
      index: pageEntity.pageIndex,
      strokes: strokes,
      thumbnailPath: pageEntity.thumbnailPath,
    );
  }

  @override
  Future<void> saveStroke({required String pageId, required StrokeData stroke}) async {
    final entity = StrokeEntity(
      id: stroke.id,
      pageId: pageId,
      brushSettingsJson: jsonEncode(stroke.brush.toJson()),
      colorValue: stroke.color.toARGB32(),
      boundingBoxJson: stroke.boundingBoxToJson(),
      geometryBlob: stroke.pointsToBlob(),
    );
    await _db.into(_db.strokes).insertOnConflictUpdate(entity);
  }

  @override
  Future<void> deleteStroke({required String pageId, required String strokeId}) async {
    await (_db.delete(_db.strokes)..where((tbl) => tbl.id.equals(strokeId))).go();
  }
}
