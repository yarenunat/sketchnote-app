import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notebook/models/notebook_models.dart';
import '../../../core/services/storage/storage_service.dart';

class LibraryViewModel extends AsyncNotifier<List<Notebook>> {
  late StorageService _storage;

  @override
  Future<List<Notebook>> build() async {
    _storage = ref.read(storageServiceProvider);
    return _storage.getAllNotebooks();
  }

  Future<void> createNotebook({required String title, required String coverAssetPath}) async {
    final newNb = await _storage.createNotebook(title: title, coverAssetPath: coverAssetPath);
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, newNb]);
  }

  Future<void> deleteNotebook(String id) async {
    await _storage.deleteNotebook(id);
    final currentList = state.value ?? [];
    state = AsyncValue.data(currentList.where((n) => n.id != id).toList());
  }

  Future<void> duplicateNotebook(String id) async {
    // Basic duplication
    final nb = await _storage.getNotebook(id);
    await createNotebook(title: '${nb.title} (Copy)', coverAssetPath: nb.coverAssetPath);
  }
}

final libraryViewModelProvider =
    AsyncNotifierProvider<LibraryViewModel, List<Notebook>>(LibraryViewModel.new);
