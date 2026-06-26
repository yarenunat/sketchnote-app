import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/notebook_viewmodel.dart';
import '../../canvas/views/canvas_view.dart';
import '../../../core/services/export/export_service.dart';

class NotebookPagerScreen extends ConsumerStatefulWidget {
  final String notebookId;

  const NotebookPagerScreen({super.key, required this.notebookId});

  @override
  ConsumerState<NotebookPagerScreen> createState() => _NotebookPagerScreenState();
}

class _NotebookPagerScreenState extends ConsumerState<NotebookPagerScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notebookAsync = ref.watch(notebookViewModelProvider(widget.notebookId));

    return notebookAsync.when(
      data: (notebook) {
        return Scaffold(
          appBar: AppBar(
            title: Text(notebook.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share),
                tooltip: 'Export',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.picture_as_pdf),
                            title: const Text('Export Notebook as Vector PDF'),
                            onTap: () async {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting PDF...')));
                              try {
                                final path = await ref.read(exportServiceProvider).exportNotebookAsPdf(notebook);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to $path')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.image),
                            title: const Text('Export Current Page as High-Res PNG'),
                            onTap: () async {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting PNG...')));
                              try {
                                final page = notebook.pages[_currentPageIndex];
                                final path = await ref.read(exportServiceProvider).exportPageAsImage(page);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to $path')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemCount: notebook.pageCount,
            itemBuilder: (context, index) {
              final page = notebook.pages[index];
              return CanvasView(pageId: page.id);
            },
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Page',
                  onPressed: () {
                    final pageId = notebook.pages[_currentPageIndex].id;
                    ref.read(notebookViewModelProvider(widget.notebookId).notifier).deletePage(pageId);
                  },
                ),
                Text('Page ${_currentPageIndex + 1} of ${notebook.pageCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  tooltip: 'Add Page',
                  onPressed: () async {
                    await ref.read(notebookViewModelProvider(widget.notebookId).notifier).addPage();
                    // Go to the new page
                    _pageController.animateToPage(
                      notebook.pageCount,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}
