import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage/storage_service.dart';
import '../models/notebook_models.dart';

class NotebookViewModel extends FamilyAsyncNotifier<Notebook, String> {
  late StorageService _storage;

  @override
  Future<Notebook> build(String arg) async {
    _storage = ref.read(storageServiceProvider);
    return _storage.getNotebook(arg);
  }

  Future<void> addPage() async {
    final nb = state.value;
    if (nb == null) return;
    
    final newPage = await _storage.addPageToNotebook(nb.id);
    state = AsyncValue.data(nb.copyWith(pages: [...nb.pages, newPage]));
  }

  Future<void> deletePage(String pageId) async {
    final nb = state.value;
    if (nb == null) return;
    if (nb.pages.length <= 1) return; // Can't delete the last page

    await _storage.deletePage(pageId);
    state = AsyncValue.data(nb.copyWith(
      pages: nb.pages.where((p) => p.id != pageId).toList(),
    ));
  }
}

final notebookViewModelProvider =
    AsyncNotifierProviderFamily<NotebookViewModel, Notebook, String>(NotebookViewModel.new);
