import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/library_viewmodel.dart';
import '../../notebook/views/notebook_pager_screen.dart';
import '../../settings/views/settings_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryViewModelProvider);

    return Scaffold(
      body: libraryAsync.when(
        data: (notebooks) => _buildBody(context, ref, notebooks, null),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) {
          // Fallback to preview mode if database fails (e.g., WebAssembly error)
          final dummyNotebooks = [
            // Using a dynamic class structure since Notebook isn't explicitly imported, we'll just mock the UI directly.
            _DummyNotebook(id: '1', title: 'Ideas & Sketches', pageCount: 12),
            _DummyNotebook(id: '2', title: 'Meeting Notes', pageCount: 4),
            _DummyNotebook(id: '3', title: 'UI Wireframes', pageCount: 7),
            _DummyNotebook(id: '4', title: 'Doodles', pageCount: 22),
          ];
          return _buildBody(context, ref, null, dummyNotebooks, errorMsg: err.toString());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(libraryViewModelProvider.notifier).createNotebook(
                title: 'New Notebook',
                coverAssetPath: '',
              );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Note', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<dynamic>? realNotebooks, List<_DummyNotebook>? dummyNotebooks, {String? errorMsg}) {
    final isPreview = dummyNotebooks != null;
    final itemsCount = isPreview ? dummyNotebooks.length : realNotebooks!.length;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120.0,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            title: Text(
              isPreview ? 'SketchNote (Preview)' : 'My Library',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        if (errorMsg != null)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Database error. Showing preview mode.\nDetails: $errorMsg',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (itemsCount == 0)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'No notebooks yet. Tap + to create one.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 0.75,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final id = isPreview ? dummyNotebooks[index].id : realNotebooks![index].id;
                  final title = isPreview ? dummyNotebooks[index].title : realNotebooks![index].title;
                  final pageCount = isPreview ? dummyNotebooks[index].pageCount : realNotebooks![index].pageCount;

                  return GestureDetector(
                    onTap: () {
                      if (!isPreview) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => NotebookPagerScreen(notebookId: id),
                        ));
                      }
                    },
                    child: Card(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Beautiful cover gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                          // Optional texture overlay or icon
                          Center(
                            child: Icon(Icons.menu_book_rounded, size: 48, color: Colors.white.withOpacity(0.5)),
                          ),
                          // Info Bar
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$pageCount pages',
                                    style: TextStyle(
                                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Actions
                          if (!isPreview)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_horiz, color: Colors.white),
                                onSelected: (action) {
                                  if (action == 'delete') {
                                    ref.read(libraryViewModelProvider.notifier).deleteNotebook(id);
                                  } else if (action == 'duplicate') {
                                    ref.read(libraryViewModelProvider.notifier).duplicateNotebook(id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: itemsCount,
              ),
            ),
          ),
      ],
    );
  }
}

class _DummyNotebook {
  final String id;
  final String title;
  final int pageCount;
  _DummyNotebook({required this.id, required this.title, required this.pageCount});
}
