import 'dart:math';
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
  double _pageValue = 0.0;

  @override
  void initState() {
    super.initState();
    // viewportFraction 0.82 allows peeking at next/prev pages
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(() {
      if (_pageController.position.haveDimensions) {
        setState(() {
          _pageValue = _pageController.page ?? 0.0;
        });
      }
    });
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
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar (Paper style)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildCircularButton(Icons.menu_book, () => Navigator.pop(context)),
                          const SizedBox(width: 12),
                          _buildCircularButton(Icons.grid_view, () {}),
                        ],
                      ),
                      Row(
                        children: [
                          _buildCircularButton(Icons.search, () {}),
                          const SizedBox(width: 12),
                          _buildCircularButton(Icons.menu, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title and Page Count
                Text(
                  notebook.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility_off, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${notebook.pageCount} Pages',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Cover Flow PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemCount: notebook.pageCount,
                    itemBuilder: (context, index) {
                      final page = notebook.pages[index];
                      // Calculate scale and offset for 3D cover flow effect
                      double value = 0.0;
                      if (_pageController.position.haveDimensions) {
                        value = index - _pageValue;
                      } else {
                        value = (index - _currentPageIndex).toDouble();
                      }
                      
                      final double scale = max(0.85, 1 - (value.abs() * 0.15));
                      final double yOffset = (value.abs() * 30);
                      
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..translate(0.0, yOffset, 0.0)
                          ..scale(scale, scale),
                        alignment: FractionalOffset.center,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // The actual drawing canvas
                              // Wrapped in AbsorbPointer if not active so we can easily swipe
                              AbsorbPointer(
                                absorbing: index != _currentPageIndex,
                                child: CanvasView(pageId: page.id),
                              ),
                              // Optional: visual overlay for inactive pages to dim them slightly
                              if (index != _currentPageIndex)
                                Container(color: Colors.black.withOpacity(0.1)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Bottom Share Button
                Container(
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.ios_share, color: Colors.black),
                    iconSize: 28,
                    padding: const EdgeInsets.all(16),
                    onPressed: () {
                      _showExportMenu(context, notebook);
                    },
                  ),
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

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        color: Colors.white.withOpacity(0.05),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 20,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(),
      ),
    );
  }

  void _showExportMenu(BuildContext context, dynamic notebook) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Share & Export',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export Notebook as PDF'),
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
            ListTile(
              leading: const Icon(Icons.add_box_outlined),
              title: const Text('Add New Page'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(notebookViewModelProvider(widget.notebookId).notifier).addPage();
                _pageController.animateToPage(
                  notebook.pageCount,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Current Page', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                final pageId = notebook.pages[_currentPageIndex].id;
                ref.read(notebookViewModelProvider(widget.notebookId).notifier).deletePage(pageId);
              },
            ),
          ],
        ),
      ),
    );
  }
}

