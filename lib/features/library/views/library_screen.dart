import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/library_viewmodel.dart';
import '../../notebook/views/notebook_pager_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SketchNote')),
      body: libraryAsync.when(
        data: (notebooks) {
          if (notebooks.isEmpty) {
            return const Center(child: Text('No notebooks yet. Tap + to create one.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 0.75,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: notebooks.length,
            itemBuilder: (context, index) {
              final nb = notebooks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => NotebookPagerScreen(notebookId: nb.id),
                  ));
                },
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.blueGrey.shade100),
                      
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(nb.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('${nb.pageCount} pages', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      
                      Positioned(
                        top: 4, right: 4,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.black54),
                          onSelected: (action) {
                            if (action == 'delete') {
                              ref.read(libraryViewModelProvider.notifier).deleteNotebook(nb.id);
                            } else if (action == 'duplicate') {
                              ref.read(libraryViewModelProvider.notifier).duplicateNotebook(nb.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(libraryViewModelProvider.notifier).createNotebook(
            title: 'New Notebook',
            coverAssetPath: '', 
          );
        },
        tooltip: 'New Notebook',
        child: const Icon(Icons.add),
      ),
    );
  }
}
