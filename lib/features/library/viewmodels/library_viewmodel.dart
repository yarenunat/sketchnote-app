import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notebook/models/notebook_models.dart';

/// Manages the list of notebooks shown in [LibraryScreen]: load from
/// storage, create, duplicate, delete, rename, reorder.
///
/// Cursor TODO:
/// - Back this with the storage service (see core/services/storage) —
///   likely Drift for metadata + filesystem for actual page/stroke data
///   (or fully inside Drift as blobs; pick one and be consistent).
/// - Generate a default set of cover styles matching the variety in the
///   reference image (solid colors, patterns, illustrated covers) for the
///   "new notebook" flow.
class LibraryState {
  final List<Notebook> notebooks;
  final bool isLoading;

  const LibraryState({this.notebooks = const [], this.isLoading = true});
}

class LibraryViewModel extends Notifier<LibraryState> {
  @override
  LibraryState build() {
    throw UnimplementedError('Cursor: load notebooks from storage on startup.');
  }

  Future<Notebook> createNotebook({required String title, required String coverAssetPath}) {
    throw UnimplementedError('Cursor: implement.');
  }

  Future<void> deleteNotebook(String id) {
    throw UnimplementedError('Cursor: implement.');
  }

  Future<Notebook> duplicateNotebook(String id) {
    throw UnimplementedError('Cursor: implement.');
  }
}

final libraryViewModelProvider =
    NotifierProvider<LibraryViewModel, LibraryState>(LibraryViewModel.new);
