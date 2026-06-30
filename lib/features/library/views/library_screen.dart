import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/library_viewmodel.dart';
import '../../notebook/views/notebook_pager_screen.dart';
import '../../notebook/widgets/create_notebook_dialog.dart';
import '../../notebook/models/notebook_models.dart';
import '../../settings/views/settings_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/app_extensions.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  double _pageValue = 0.0;
  bool _isGridView = false;
  bool _isSearching = false;
  final _searchController = TextEditingController();

  // Background animation
  late AnimationController _bgAnim;
  late Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.72);
    _pageController.addListener(() {
      if (_pageController.position.haveDimensions) {
        setState(() => _pageValue = _pageController.page ?? 0.0);
      }
    });

    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bgOpacity = CurvedAnimation(parent: _bgAnim, curve: Curves.easeOut);
    _bgAnim.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _bgAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(libraryViewModelProvider);

    return stateAsync.when(
      data: (state) => _buildBody(context, state),
      loading: () => _buildLoadingScaffold(),
      error: (_, __) => _buildBody(context, _demoState()),
    );
  }

  Widget _buildLoadingScaffold() {
    return const Scaffold(
      backgroundColor: Color(0xFF1E2028),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 2),
      ),
    );
  }

  LibraryState _demoState() {
    final now = DateTime.now();
    return LibraryState(notebooks: [
      Notebook(
        id: '1',
        title: 'Illustrations',
        pages: List.generate(16, (i) => NotebookPage(id: 'p$i', index: i)),
        coverAssetPath: '',
        coverColorValue: 0xFF8B1A1A,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Notebook(
        id: '2',
        title: 'Sketchnoting',
        pages: List.generate(24, (i) => NotebookPage(id: 'q$i', index: i)),
        coverAssetPath: '',
        coverColorValue: 0xFF1B3A6B,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Notebook(
        id: '3',
        title: 'Meeting Notes',
        pages: List.generate(8, (i) => NotebookPage(id: 'r$i', index: i)),
        coverAssetPath: '',
        coverColorValue: 0xFF1F4E3D,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Notebook(
        id: '4',
        title: 'UI Wireframes',
        pages: List.generate(12, (i) => NotebookPage(id: 's$i', index: i)),
        coverAssetPath: '',
        coverColorValue: 0xFF4A1C40,
        createdAt: now,
      ),
    ]);
  }

  Widget _buildBody(BuildContext context, LibraryState state) {
    final notebooks = state.filtered;
    final count = notebooks.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1E2028),
      body: FadeTransition(
        opacity: _bgOpacity,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Navigation Bar ──────────────────────────────────
              _buildTopBar(context, state),

              // ── Search Bar ─────────────────────────────────────────
              if (_isSearching) _buildSearchBar(context),

              const SizedBox(height: 12),

              // ── Notebook Title & Info ─────────────────────────────
              if (!_isSearching && count > 0 && !_isGridView)
                _buildNotebookInfo(context, notebooks),

              if (!_isGridView) const SizedBox(height: 24),

              // ── Content (Carousel or Grid) ─────────────────────────
              Expanded(
                child: count == 0
                    ? _buildEmptyState(context)
                    : _isGridView
                        ? _buildGrid(context, state, notebooks)
                        : _buildCarousel(context, state, notebooks),
              ),

              // ── Bottom Action Bar ─────────────────────────────────
              _buildBottomBar(context, state, notebooks),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context, LibraryState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // View toggle
          _TopBtn(
            icon: _isGridView ? Icons.view_carousel_rounded : Icons.grid_view_rounded,
            onTap: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 10),
          // Sort button
          _TopBtn(
            icon: Icons.sort,
            onTap: () => _showSortMenu(context, state),
          ),
          const Spacer(),
          // Logo / App name
          Text(
            'SketchNote',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Search
          _TopBtn(
            icon: Icons.search,
            isActive: _isSearching,
            onTap: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                ref.read(libraryViewModelProvider.notifier).setSearchQuery('');
              }
            }),
          ),
          const SizedBox(width: 10),
          // Settings
          _TopBtn(
            icon: Icons.tune,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Search notebooks...',
            hintStyle: TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref
                          .read(libraryViewModelProvider.notifier)
                          .setSearchQuery('');
                    },
                    child: const Icon(Icons.close, color: Colors.white38, size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (v) =>
              ref.read(libraryViewModelProvider.notifier).setSearchQuery(v),
        ),
      ),
    );
  }

  // ── Notebook info row ──────────────────────────────────────────────────

  Widget _buildNotebookInfo(BuildContext context, List<Notebook> notebooks) {
    if (_currentIndex >= notebooks.length) return const SizedBox.shrink();
    final nb = notebooks[_currentIndex];
    return Column(
      children: [
        Text(
          nb.title,
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.layers_outlined, color: Colors.white54, size: 14),
            const SizedBox(width: 5),
            Text(
              '${nb.pageCount} Pages',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            if (nb.createdAt != null) ...[
              const SizedBox(width: 12),
              const Icon(Icons.access_time, color: Colors.white38, size: 12),
              const SizedBox(width: 4),
              Text(
                _formatDate(nb.createdAt!),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ── Carousel ──────────────────────────────────────────────────────────

  Widget _buildCarousel(BuildContext context, LibraryState state, List<Notebook> notebooks) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (i) => setState(() => _currentIndex = i),
      itemCount: notebooks.length,
      itemBuilder: (context, index) {
        final nb = notebooks[index];
        double offset = 0.0;
        if (_pageController.position.haveDimensions) {
          offset = index - _pageValue;
        } else {
          offset = (index - _currentIndex).toDouble();
        }
        final double scale = max(0.87, 1 - offset.abs() * 0.13);
        final double yOff = offset.abs() * 22;

        return GestureDetector(
          onTap: () => _openNotebook(context, nb),
          onLongPress: () => _showNotebookMenu(context, state, nb),
          child: Transform(
            transform: Matrix4.identity()
              ..translate(0.0, yOff)
              ..scale(scale, scale),
            alignment: FractionalOffset.center,
            child: _JournalCoverCard(notebook: nb, index: index),
          ),
        );
      },
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────

  Widget _buildGrid(BuildContext context, LibraryState state, List<Notebook> notebooks) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: notebooks.length,
      itemBuilder: (context, index) {
        final nb = notebooks[index];
        return GestureDetector(
          onTap: () => _openNotebook(context, nb),
          onLongPress: () => _showNotebookMenu(context, state, nb),
          child: _JournalCoverCard(notebook: nb, index: index, isGrid: true),
        );
      },
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded, size: 64, color: Colors.white.withAlpha(40)),
          const SizedBox(height: 16),
          Text(
            'No notebooks yet',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white54,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first notebook',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, LibraryState state, List<Notebook> notebooks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BottomBtn(
            icon: Icons.more_horiz,
            onTap: () {
              if (notebooks.isNotEmpty && _currentIndex < notebooks.length) {
                _showNotebookMenu(context, state, notebooks[_currentIndex]);
              }
            },
          ),
          const SizedBox(width: 14),
          _BottomBtn(
            icon: Icons.ios_share,
            onTap: () {},
          ),
          const SizedBox(width: 14),
          _BottomBtn(
            icon: Icons.delete_outline,
            onTap: () {
              if (notebooks.isNotEmpty && _currentIndex < notebooks.length) {
                ref
                    .read(libraryViewModelProvider.notifier)
                    .deleteNotebook(notebooks[_currentIndex].id);
              }
            },
          ),
          const SizedBox(width: 14),
          _BottomBtn(
            icon: Icons.add,
            filled: true,
            onTap: () => _createNotebook(context),
          ),
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────

  void _openNotebook(BuildContext context, Notebook nb) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NotebookPagerScreen(notebookId: nb.id),
    ));
  }

  Future<void> _createNotebook(BuildContext context) async {
    final result = await CreateNotebookDialog.show(context);
    if (result == null) return;
    await ref.read(libraryViewModelProvider.notifier).createNotebook(
          title: result.title,
          coverAssetPath: '',
          coverColorValue: result.coverColorValue,
        );
  }

  void _showNotebookMenu(BuildContext context, LibraryState state, Notebook nb) {
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(nb.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Open'),
              onTap: () {
                Navigator.pop(context);
                _openNotebook(context, nb);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(libraryViewModelProvider.notifier)
                    .duplicateNotebook(nb.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref
                    .read(libraryViewModelProvider.notifier)
                    .deleteNotebook(nb.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(BuildContext context, LibraryState state) {
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
              child: Text('Sort Notebooks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final mode in SortMode.values)
              ListTile(
                leading: Icon(
                  _sortIcon(mode),
                  color: state.sortMode == mode
                      ? AppColors.accent
                      : null,
                ),
                title: Text(_sortLabel(mode)),
                trailing: state.sortMode == mode
                    ? Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () {
                  ref
                      .read(libraryViewModelProvider.notifier)
                      .setSortMode(mode);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _sortIcon(SortMode mode) {
    switch (mode) {
      case SortMode.name:
        return Icons.sort_by_alpha;
      case SortMode.dateModified:
        return Icons.update;
      case SortMode.dateCreated:
        return Icons.calendar_today;
    }
  }

  String _sortLabel(SortMode mode) {
    switch (mode) {
      case SortMode.name:
        return 'By Name';
      case SortMode.dateModified:
        return 'Last Modified';
      case SortMode.dateCreated:
        return 'Date Created';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _JournalCoverCard extends StatelessWidget {
  final Notebook notebook;
  final int index;
  final bool isGrid;

  const _JournalCoverCard({
    required this.notebook,
    required this.index,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    // Pick gradient from cover gradients by color value match, or by index
    final coverColor = Color(notebook.coverColorValue);
    final gradientColors = AppColors.coverGradients[index % AppColors.coverGradients.length];

    return Container(
      margin: isGrid
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isGrid ? 12 : 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 28,
            offset: const Offset(6, 12),
          ),
          BoxShadow(
            color: coverColor.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 0.72,
        child: CustomPaint(
          painter: _NotebookCoverPainter(
            coverColor: coverColor,
            accentColor: gradientColors.last,
            index: index,
          ),
          child: isGrid
              ? _buildGridInfo(context, notebook)
              : null,
        ),
      ),
    );
  }

  Widget _buildGridInfo(BuildContext context, Notebook nb) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withAlpha(120),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nb.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${nb.pageCount} pages',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotebookCoverPainter extends CustomPainter {
  final Color coverColor;
  final Color accentColor;
  final int index;

  _NotebookCoverPainter({
    required this.coverColor,
    required this.accentColor,
    required this.index,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(index * 7 + 13);
    final spineWidth = size.width * 0.06;

    // Spine shadow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, spineWidth, size.height),
      Paint()..color = Colors.black.withAlpha(90),
    );

    // Cover background
    canvas.drawRect(
      Rect.fromLTWH(spineWidth, 0, size.width - spineWidth, size.height),
      Paint()..color = coverColor,
    );

    // Subtle ruled lines texture
    final linePaint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..strokeWidth = 0.8;
    for (double y = 20; y < size.height; y += 18) {
      canvas.drawLine(
          Offset(spineWidth, y), Offset(size.width, y), linePaint);
    }

    // Label area
    final labelRect = Rect.fromLTWH(
      spineWidth + size.width * 0.08,
      size.height * 0.28,
      size.width * 0.75,
      size.height * 0.32,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      Paint()..color = Colors.white.withAlpha(30),
    );

    // Accent dot
    canvas.drawCircle(
      Offset(spineWidth + size.width * 0.12, size.height * 0.18),
      6,
      Paint()..color = accentColor.withAlpha(180),
    );
    canvas.drawCircle(
      Offset(spineWidth + size.width * 0.12, size.height * 0.18),
      3,
      Paint()..color = Colors.white.withAlpha(230),
    );

    // Corner fold
    final foldPath = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width - 18, size.height)
      ..lineTo(size.width, size.height - 18)
      ..close();
    canvas.drawPath(foldPath, Paint()..color = Colors.black.withAlpha(50));

    // Spiral rings
    final ringPaint = Paint()
      ..color = Colors.white.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final ringFill = Paint()
      ..color = Colors.white.withAlpha(40)
      ..style = PaintingStyle.fill;
    const ringCount = 7;
    final ringSpacing = size.height / (ringCount + 1);
    for (int i = 1; i <= ringCount; i++) {
      final cy = ringSpacing * i;
      final rect = Rect.fromCenter(
        center: Offset(spineWidth / 2, cy),
        width: spineWidth * 1.1,
        height: ringSpacing * 0.38,
      );
      canvas.drawOval(rect, ringFill);
      canvas.drawOval(rect, ringPaint);
    }

    // Vignette
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [Colors.transparent, Colors.black.withAlpha(46)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(_NotebookCoverPainter old) => false;
}

class _TopBtn extends StatelessWidget {
  const _TopBtn({required this.icon, required this.onTap, this.isActive = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Colors.white.withAlpha(25)
              : Colors.white.withAlpha(15),
          border: Border.all(
            color: isActive
                ? Colors.white.withAlpha(80)
                : Colors.white.withAlpha(30),
          ),
        ),
        child: Icon(icon,
            color: isActive ? Colors.white : Colors.white60, size: 18),
      ),
    );
  }
}

class _BottomBtn extends StatelessWidget {
  const _BottomBtn({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? Colors.white : Colors.white.withAlpha(15),
          border: Border.all(color: Colors.white.withAlpha(40)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(80),
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
