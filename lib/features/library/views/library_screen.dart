import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/library_viewmodel.dart';
import '../../notebook/views/notebook_pager_screen.dart';
import '../../settings/views/settings_screen.dart';

// Paper app cover color palettes
const List<List<Color>> _coverGradients = [
  [Color(0xFFE8504A), Color(0xFF3B7BD9), Color(0xFFE8C84A), Color(0xFF2DB09A)], // Geometric multi
  [Color(0xFF6B4FA0), Color(0xFFD4A0FF)], // Purple
  [Color(0xFF1A936F), Color(0xFF88D498)], // Green
  [Color(0xFFE63946), Color(0xFFFF9F1C)], // Red-Orange
  [Color(0xFF457B9D), Color(0xFFA8DADC)], // Blue
  [Color(0xFFE76F51), Color(0xFFF4A261)], // Terracotta
];

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  double _pageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.72);
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
    final libraryAsync = ref.watch(libraryViewModelProvider);

    return libraryAsync.when(
      data: (notebooks) => _buildBody(context, ref, notebooks, null),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF262D3C),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (err, st) {
        final dummyNotebooks = [
          _DummyNotebook(id: '1', title: 'Illustrations', pageCount: 16),
          _DummyNotebook(id: '2', title: 'Sketchnoting', pageCount: 24),
          _DummyNotebook(id: '3', title: 'Meeting Notes', pageCount: 8),
          _DummyNotebook(id: '4', title: 'UI Wireframes', pageCount: 12),
        ];
        return _buildBody(context, ref, null, dummyNotebooks);
      },
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      List<dynamic>? realNotebooks, List<_DummyNotebook>? dummyNotebooks) {
    final isPreview = dummyNotebooks != null;
    final count = isPreview ? dummyNotebooks.length : realNotebooks!.length;

    String currentTitle = '';
    int currentPageCount = 0;
    if (count > 0) {
      currentTitle = isPreview
          ? dummyNotebooks[_currentIndex].title
          : realNotebooks![_currentIndex].title;
      currentPageCount = isPreview
          ? dummyNotebooks[_currentIndex].pageCount
          : realNotebooks![_currentIndex].pageCount;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF262D3C),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ──────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.menu_book_rounded,
                    onTap: () {},
                  ),
                  _buildCircleButton(
                    icon: Icons.grid_view_rounded,
                    onTap: () {},
                  ),
                  const Spacer(),
                  _buildCircleButton(
                    icon: Icons.search,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildCircleButton(
                    icon: Icons.menu,
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Title & Page Count ───────────────────────────────
            if (count > 0) ...[
              Text(
                currentTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_outlined,
                      color: Colors.white54, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    '$currentPageCount Pages',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 28),

            // ── Cover Flow ───────────────────────────────────────
            Expanded(
              child: count == 0
                  ? const Center(
                      child: Text('No notebooks yet.',
                          style: TextStyle(color: Colors.white54, fontSize: 16)))
                  : PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemCount: count,
                      itemBuilder: (context, index) {
                        final id = isPreview
                            ? dummyNotebooks[index].id
                            : realNotebooks![index].id;
                        final colorSet =
                            _coverGradients[index % _coverGradients.length];

                        double offset = 0.0;
                        if (_pageController.position.haveDimensions) {
                          offset = index - _pageValue;
                        } else {
                          offset = (index - _currentIndex).toDouble();
                        }
                        final double scale =
                            max(0.88, 1 - offset.abs() * 0.12);
                        final double yOff = offset.abs() * 20;

                        return GestureDetector(
                          onTap: () {
                            if (!isPreview) {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    NotebookPagerScreen(notebookId: id),
                              ));
                            }
                          },
                          child: Transform(
                            transform: Matrix4.identity()
                              ..translate(0.0, yOff, 0.0)
                              ..scale(scale, scale),
                            alignment: FractionalOffset.center,
                            child: _JournalCoverCard(
                              colors: colorSet,
                              index: index,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            // ── Bottom Action Bar ────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBottomButton(Icons.more_horiz, () {}),
                  const SizedBox(width: 16),
                  _buildBottomButton(Icons.ios_share, () {}),
                  const SizedBox(width: 16),
                  _buildBottomButton(Icons.delete_outline, () {
                    if (!isPreview && count > 0) {
                      final id = realNotebooks![_currentIndex].id;
                      ref
                          .read(libraryViewModelProvider.notifier)
                          .deleteNotebook(id);
                    }
                  }),
                  const SizedBox(width: 16),
                  _buildBottomButton(Icons.add, () {
                    ref.read(libraryViewModelProvider.notifier).createNotebook(
                          title: 'New Notebook ${count + 1}',
                          coverAssetPath: '',
                        );
                  }, filled: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildBottomButton(IconData icon, VoidCallback onTap,
      {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? Colors.white : Colors.white.withOpacity(0.07),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: filled
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Icon(icon,
            color: filled ? Colors.black : Colors.white, size: 22),
      ),
    );
  }
}

/// Decorative journal cover widget — mimics the geometric cover from the screenshot.
class _JournalCoverCard extends StatelessWidget {
  final List<Color> colors;
  final int index;

  const _JournalCoverCard({required this.colors, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 12))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 0.75,
        child: CustomPaint(
          painter: _GeometricCoverPainter(colors: colors, seed: index),
        ),
      ),
    );
  }
}

/// Draws a colorful geometric cover pattern inspired by the Paper app.
class _GeometricCoverPainter extends CustomPainter {
  final List<Color> colors;
  final int seed;

  _GeometricCoverPainter({required this.colors, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed * 137 + 42);
    final bg = colors[0];
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = bg);

    final shapes = 12 + rng.nextInt(8);
    for (int i = 0; i < shapes; i++) {
      final color = colors[rng.nextInt(colors.length)]
          .withOpacity(0.6 + rng.nextDouble() * 0.4);
      final paint = Paint()..color = color;
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 20.0 + rng.nextDouble() * 60;
      final shapeType = rng.nextInt(4);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rng.nextDouble() * 3.14);
      switch (shapeType) {
        case 0:
          canvas.drawCircle(Offset.zero, r * 0.5, paint);
          break;
        case 1:
          canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: r, height: r), paint);
          break;
        case 2:
          final path = Path()
            ..moveTo(0, -r * 0.6)
            ..lineTo(r * 0.5, r * 0.4)
            ..lineTo(-r * 0.5, r * 0.4)
            ..close();
          canvas.drawPath(path, paint);
          break;
        case 3:
          canvas.drawRect(
              Rect.fromCenter(center: Offset.zero, width: r * 1.2, height: r * 0.4), paint);
          break;
      }
      canvas.restore();
    }

    // Subtle grid lines like the screenshot
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += size.width / 4) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += size.height / 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_GeometricCoverPainter old) => false;
}

class _DummyNotebook {
  final String id;
  final String title;
  final int pageCount;
  _DummyNotebook(
      {required this.id, required this.title, required this.pageCount});
}
