import '../../../features/notebook/models/notebook_models.dart';

/// High-level persistence API used by viewmodels. Hides whether data
/// actually lives in Drift, flat files, or a hybrid — viewmodels should
/// never import Drift types directly.
///
/// Cursor TODO: implement against app_database.dart once that schema is
/// generated. Keep all methods async and batched (e.g. saving a finished
/// stroke should not block the UI thread or stall mid-drawing).
abstract class StorageService {
  Future<List<Notebook>> getAllNotebooks();

  Future<Notebook> createNotebook({required String title, required String coverAssetPath});

  Future<void> deleteNotebook(String id);

  Future<NotebookPage> getPage(String pageId);

  Future<void> saveStroke({required String pageId, required StrokeData stroke});

  Future<void> deleteStroke({required String pageId, required String strokeId});
}
