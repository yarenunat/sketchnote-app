import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notebook/models/notebook_models.dart';
import '../../../core/services/storage/storage_service.dart';

enum SortMode { dateCreated, name, dateModified }

class LibraryState {
  final List<Notebook> notebooks;
  final String searchQuery;
  final SortMode sortMode;

  const LibraryState({
    this.notebooks = const [],
    this.searchQuery = '',
    this.sortMode = SortMode.dateCreated,
  });

  List<Notebook> get filtered {
    var result = notebooks.toList();

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((n) => n.title.toLowerCase().contains(q)).toList();
    }

    // Sort
    switch (sortMode) {
      case SortMode.name:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortMode.dateModified:
        result.sort((a, b) {
          final aTime = a.modifiedAt ?? DateTime(2000);
          final bTime = b.modifiedAt ?? DateTime(2000);
          return bTime.compareTo(aTime); // Newest first
        });
        break;
      case SortMode.dateCreated:
      default:
        result.sort((a, b) {
          final aTime = a.createdAt ?? DateTime(2000);
          final bTime = b.createdAt ?? DateTime(2000);
          return bTime.compareTo(aTime); // Newest first
        });
        break;
    }

    return result;
  }

  LibraryState copyWith({
    List<Notebook>? notebooks,
    String? searchQuery,
    SortMode? sortMode,
  }) {
    return LibraryState(
      notebooks: notebooks ?? this.notebooks,
      searchQuery: searchQuery ?? this.searchQuery,
      sortMode: sortMode ?? this.sortMode,
    );
  }
}

class LibraryViewModel extends AsyncNotifier<LibraryState> {
  late StorageService _storage;

  @override
  Future<LibraryState> build() async {
    _storage = ref.read(storageServiceProvider);
    final notebooks = await _storage.getAllNotebooks();
    return LibraryState(notebooks: notebooks);
  }

  Future<void> createNotebook({
    required String title,
    required String coverAssetPath,
    int coverColorValue = 0xFF8B1A1A,
  }) async {
    final newNb = await _storage.createNotebook(
        title: title, coverAssetPath: coverAssetPath);
    final currentState = state.value ?? const LibraryState();
    state = AsyncValue.data(currentState.copyWith(
      notebooks: [...currentState.notebooks, newNb.copyWith(
        coverColorValue: coverColorValue,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      )],
    ));
  }

  Future<void> deleteNotebook(String id) async {
    await _storage.deleteNotebook(id);
    final currentState = state.value ?? const LibraryState();
    state = AsyncValue.data(currentState.copyWith(
      notebooks: currentState.notebooks.where((n) => n.id != id).toList(),
    ));
  }

  Future<void> duplicateNotebook(String id) async {
    final nb = await _storage.getNotebook(id);
    await createNotebook(
      title: '${nb.title} (Copy)',
      coverAssetPath: nb.coverAssetPath,
      coverColorValue: nb.coverColorValue,
    );
  }

  void setSearchQuery(String query) {
    final currentState = state.value ?? const LibraryState();
    state = AsyncValue.data(currentState.copyWith(searchQuery: query));
  }

  void setSortMode(SortMode mode) {
    final currentState = state.value ?? const LibraryState();
    state = AsyncValue.data(currentState.copyWith(sortMode: mode));
  }
}

final libraryViewModelProvider =
    AsyncNotifierProvider<LibraryViewModel, LibraryState>(LibraryViewModel.new);
