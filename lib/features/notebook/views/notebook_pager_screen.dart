import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/notebook_viewmodel.dart';
import '../models/notebook_models.dart';
import '../widgets/page_background_painter.dart';
import '../widgets/page_template_selector.dart';
import '../../canvas/views/canvas_view.dart';
import '../../../core/services/export/export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/page_flip_widget.dart';
import '../../../shared/extensions/app_extensions.dart';

/// The notebook reader/editor screen with 3D page-flip navigation.
///
/// The screen has two modes:
///  - **OVERVIEW mode** (default): shows the cover-flow thumbnail carousel
///    where you can swipe between page cards.
///  - **EDIT mode**: opens a specific page full-screen for drawing.
///
/// In OVERVIEW mode, the [PageFlipWidget] is used for inter-page navigation.
/// In EDIT mode, [CanvasView] fills the entire screen.
class NotebookPagerScreen extends ConsumerStatefulWidget {
  final String notebookId;
  const NotebookPagerScreen({super.key, required this.notebookId});

  @override
  ConsumerState<NotebookPagerScreen> createState() =>
      _NotebookPagerScreenState();
}

class _NotebookPagerScreenState extends ConsumerState<NotebookPagerScreen>
    with TickerProviderStateMixin {
  int _currentPageIndex = 0;
  bool _isEditMode = false;

  // For the cover-flow overview
  late PageController _overviewController;
  double _overviewPageValue = 0.0;

  // Page flip state
  int _flipKey = 0; // Incremented to force PageFlipWidget rebuild on nav

  @override
  void initState() {
    super.initState();
    _overviewController = PageController(viewportFraction: 0.82);
    _overviewController.addListener(() {
      if (_overviewController.position.haveDimensions) {
        setState(() => _overviewPageValue = _overviewController.page ?? 0.0);
      }
    });
  }

  @override
  void dispose() {
    _overviewController.dispose();
    super.dispose();
  }

  void _enterEditMode(int pageIndex) {
    setState(() {
      _currentPageIndex = pageIndex;
      _isEditMode = true;
    });
  }

  void _exitEditMode() {
    setState(() => _isEditMode = false);
  }

  void _flipToNext(List<NotebookPage> pages) {
    if (_currentPageIndex < pages.length - 1) {
      setState(() {
        _currentPageIndex++;
        _flipKey++;
      });
    }
  }

  void _flipToPrev(List<NotebookPage> pages) {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
        _flipKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notebookAsync = ref.watch(notebookViewModelProvider(widget.notebookId));

    return notebookAsync.when(
      data: (notebook) => _buildScaffold(context, notebook),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, Notebook notebook) {
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkSlate : const Color(0xFF2D3250);

    return Scaffold(
      backgroundColor: bg,
      body: _isEditMode
          ? _buildEditMode(context, notebook)
          : _buildOverviewMode(context, notebook),
    );
  }

  // ── Edit Mode (full-screen canvas with 3D page flip) ────────────────────

  Widget _buildEditMode(BuildContext context, Notebook notebook) {
    if (notebook.pages.isEmpty) return const SizedBox.shrink();

    final hasPrev = _currentPageIndex > 0;
    final hasNext = _currentPageIndex < notebook.pages.length - 1;
    final currentPage = notebook.pages[_currentPageIndex];
    final prevPage = hasPrev ? notebook.pages[_currentPageIndex - 1] : null;
    final nextPage = hasNext ? notebook.pages[_currentPageIndex + 1] : null;

    return SafeArea(
      child: Stack(
        children: [
          // ── Page flip widget ─────────────────────────────────────────
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80), // Space for toolbar
              child: PageFlipWidget(
                key: ValueKey('flip_$_flipKey'),
                currentPage: _buildPageContent(currentPage),
                nextPage: nextPage != null
                    ? _buildPageContent(nextPage)
                    : _buildEmptyPageHint(context),
                previousPage: prevPage != null
                    ? _buildPageContent(prevPage)
                    : null,
                onFlipForward: hasNext
                    ? () => _flipToNext(notebook.pages)
                    : () {},
                onFlipBackward: hasPrev
                    ? () => _flipToPrev(notebook.pages)
                    : null,
                allowBackwardFlip: hasPrev,
              ),
            ),
          ),

          // ── Edit mode top bar ─────────────────────────────────────────
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: _buildEditModeTopBar(context, notebook),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(NotebookPage page) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Page background texture
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: PageBackgroundPainter(type: page.backgroundType),
              ),
            ),
          ),
          // Drawing canvas
          Positioned.fill(
            child: CanvasView(pageId: page.id),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPageHint(BuildContext context) {
    return Container(
      color: AppColors.warmWhite,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline,
                size: 48, color: AppColors.warmGray300),
            const SizedBox(height: 12),
            Text(
              'Add a new page',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.warmGray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditModeTopBar(BuildContext context, Notebook notebook) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back to overview
          _CircularBtn(
            icon: Icons.menu_book_rounded,
            onTap: _exitEditMode,
          ),
          const SizedBox(width: 10),
          // Page indicator
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPageIndex + 1} / ${notebook.pageCount}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          // Template selector
          _CircularBtn(
            icon: Icons.format_line_spacing,
            onTap: () => PageTemplateSelector.show(
              context: context,
              currentType:
                  notebook.pages[_currentPageIndex].backgroundType,
              onSelected: (type) => ref
                  .read(notebookViewModelProvider(widget.notebookId).notifier)
                  .setPageBackground(_currentPageIndex, type),
            ),
          ),
          const SizedBox(width: 10),
          // Share/export
          _CircularBtn(
            icon: Icons.ios_share,
            onTap: () => _showExportMenu(context, notebook),
          ),
        ],
      ),
    );
  }

  // ── Overview Mode (carousel) ─────────────────────────────────────────────

  Widget _buildOverviewMode(BuildContext context, Notebook notebook) {
    return SafeArea(
      child: Column(
        children: [
          // ── Top bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _CircularBtn(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                _CircularBtn(icon: Icons.grid_view, onTap: () {}),
                const Spacer(),
                _CircularBtn(icon: Icons.search, onTap: () {}),
                const SizedBox(width: 12),
                _CircularBtn(
                  icon: Icons.ios_share,
                  onTap: () => _showExportMenu(context, notebook),
                ),
              ],
            ),
          ),

          // ── Title ──────────────────────────────────────────────────
          Text(
            notebook.title,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.layers_outlined,
                  color: Colors.white54, size: 14),
              const SizedBox(width: 6),
              Text(
                '${notebook.pageCount} Pages',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Cover-flow page carousel ────────────────────────────────
          Expanded(
            child: notebook.pages.isEmpty
                ? Center(
                    child: Text(
                      'No pages yet.',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : PageView.builder(
                    controller: _overviewController,
                    onPageChanged: (i) =>
                        setState(() => _currentPageIndex = i),
                    itemCount: notebook.pages.length,
                    itemBuilder: (context, index) {
                      final page = notebook.pages[index];
                      final offset = index - _overviewPageValue;
                      final scale = max(0.85, 1.0 - offset.abs() * 0.12);
                      final yOff = offset.abs() * 24;

                      return GestureDetector(
                        onTap: () => _enterEditMode(index),
                        child: Transform(
                          transform: Matrix4.identity()
                            // ignore: deprecated_member_use
                            ..translate(0.0, yOff)
                            // ignore: deprecated_member_use
                            ..scale(scale, scale),
                          alignment: FractionalOffset.center,
                          child: _PageCard(page: page),
                        ),
                      );
                    },
                  ),
          ),

          // ── Bottom actions ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BottomBtn(
                  icon: Icons.delete_outline,
                  onTap: () {
                    if (notebook.pages.length > 1) {
                      ref
                          .read(notebookViewModelProvider(
                                  widget.notebookId)
                              .notifier)
                          .deletePage(
                              notebook.pages[_currentPageIndex].id);
                    }
                  },
                ),
                const SizedBox(width: 16),
                _BottomBtn(
                  icon: Icons.format_line_spacing,
                  onTap: () => PageTemplateSelector.show(
                    context: context,
                    currentType: notebook.pages[_currentPageIndex].backgroundType,
                    onSelected: (type) => ref
                        .read(notebookViewModelProvider(widget.notebookId)
                            .notifier)
                        .setPageBackground(_currentPageIndex, type),
                  ),
                ),
                const SizedBox(width: 16),
                _BottomBtn(
                  icon: Icons.add,
                  filled: true,
                  onTap: () async {
                    await ref
                        .read(notebookViewModelProvider(widget.notebookId)
                            .notifier)
                        .addPage();
                    final nb = ref
                        .read(notebookViewModelProvider(widget.notebookId))
                        .value;
                    if (nb != null) {
                      _overviewController.animateToPage(
                        nb.pageCount - 1,
                        duration: AppDurations.normal,
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Export menu ──────────────────────────────────────────────────────────

  void _showExportMenu(BuildContext context, Notebook notebook) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.warmGray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Share & Export',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () async {
                Navigator.pop(context);
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Exporting PDF...')),
                );
                try {
                  final path = await ref
                      .read(exportServiceProvider)
                      .exportNotebookAsPdf(notebook);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Saved to \$path')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Export failed: \$e'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Export Current Page as PNG'),
              onTap: () async {
                Navigator.pop(context);
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Exporting PNG...')),
                );
                try {
                  final page = notebook.pages[_currentPageIndex];
                  final path = await ref
                      .read(exportServiceProvider)
                      .exportPageAsImage(page);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Saved to \$path')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Export failed: \$e'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PageCard extends StatelessWidget {
  final NotebookPage page;
  const _PageCard({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: PageBackgroundPainter(type: page.backgroundType),
        child: Center(
          child: Icon(
            Icons.touch_app_outlined,
            size: 40,
            color: AppColors.warmGray300,
          ),
        ),
      ),
    );
  }
}

class _CircularBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircularBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(15),
          border: Border.all(color: Colors.white.withAlpha(40), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _BottomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _BottomBtn({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? Colors.white : Colors.white.withAlpha(20),
          border: Border.all(color: Colors.white.withAlpha(40)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Icon(icon,
            color: filled ? Colors.black : Colors.white, size: 22),
      ),
    );
  }
}
