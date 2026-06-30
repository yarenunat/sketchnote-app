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
    state = AsyncValue.data(
        nb.copyWith(pages: nb.pages.where((p) => p.id != pageId).toList()));
  }

  /// Updates the background template for a specific page (in-memory only;
  /// a full DB column would require a schema migration — stored in-memory for v1).
  void setPageBackground(int pageIndex, PageBackgroundType type) {
    final nb = state.value;
    if (nb == null) return;
    if (pageIndex < 0 || pageIndex >= nb.pages.length) return;

    final newPages = List<NotebookPage>.from(nb.pages);
    newPages[pageIndex] = newPages[pageIndex].copyWith(backgroundType: type);
    state = AsyncValue.data(nb.copyWith(pages: newPages));
  }
}

final notebookViewModelProvider =
    AsyncNotifierProviderFamily<NotebookViewModel, Notebook, String>(
        NotebookViewModel.new);
