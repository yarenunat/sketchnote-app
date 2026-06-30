import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/library_viewmodel.dart';
import '../../notebook/views/notebook_pager_screen.dart';
import '../../settings/views/settings_screen.dart';

// Rich physical notebook cover colors — each pair is [cover, accent]
const List<List<Color>> _coverGradients = [
  [Color(0xFF8B1A1A), Color(0xFFFFD700)],   // Deep burgundy / gold
  [Color(0xFF1B3A6B), Color(0xFF7EB8F7)],   // Navy / sky blue
  [Color(0xFF1F4E3D), Color(0xFFA8E6CF)],   // Forest green / mint
  [Color(0xFF4A1C40), Color(0xFFE8A0C0)],   // Plum / rose
  [Color(0xFF8B4513), Color(0xFFF4A261)],   // Saddle brown / amber
  [Color(0xFF2D3250), Color(0xFF7B8FD4)],   // Slate navy / periwinkle
  [Color(0xFF3D1C02), Color(0xFFD4A57A)],   // Dark leather / tan
  [Color(0xFF0D3B2E), Color(0xFF52B788)],   // Cypress / sage
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

/// Decorative journal cover widget — mimics a physical spiral notebook.
class _JournalCoverCard extends StatelessWidget {
  final List<Color> colors;
  final int index;

  const _JournalCoverCard({required this.colors, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 28,
              offset: const Offset(6, 12)),
          BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 0.72,
        child: CustomPaint(
          painter: _NotebookCoverPainter(colors: colors, index: index),
        ),
      ),
    );
  }
}

/// Draws a realistic physical notebook cover.
class _NotebookCoverPainter extends CustomPainter {
  final List<Color> colors;
  final int index;

  _NotebookCoverPainter({required this.colors, required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(index * 7 + 13);
    final coverColor = colors[0];
    final accentColor = colors.length > 1 ? colors[1] : colors[0].withOpacity(0.5);

    // ── Shadow/depth on the left (spine effect) ──────────────
    final spineWidth = size.width * 0.06;
    final spinePaint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawRect(Rect.fromLTWH(0, 0, spineWidth, size.height), spinePaint);

    // ── Book cover (main body) ────────────────────────────────
    final coverPaint = Paint()..color = coverColor;
    canvas.drawRect(
        Rect.fromLTWH(spineWidth, 0, size.width - spineWidth, size.height),
        coverPaint);

    // ── Subtle texture (horizontal ruled lines) ───────────────
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.8;
    for (double y = 20; y < size.height; y += 18) {
      canvas.drawLine(
          Offset(spineWidth, y), Offset(size.width, y), linePaint);
    }

    // ── Accent stripe / label area ────────────────────────────
    final labelRect = Rect.fromLTWH(
        spineWidth + size.width * 0.08,
        size.height * 0.28,
        size.width * 0.75,
        size.height * 0.32);
    final labelPaint = Paint()
      ..color = Colors.white.withOpacity(0.12);
    final rrect = RRect.fromRectAndRadius(labelRect, const Radius.circular(4));
    canvas.drawRRect(rrect, labelPaint);
    
    // ── Decorative accent dot or stripe ──────────────────────
    final accentPaint = Paint()..color = accentColor.withOpacity(0.7);
    final dotX = spineWidth + size.width * 0.12;
    canvas.drawCircle(Offset(dotX, size.height * 0.18), 6, accentPaint);
    canvas.drawCircle(Offset(dotX, size.height * 0.18), 3,
        Paint()..color = Colors.white.withOpacity(0.9));

    // ── Corner fold ───────────────────────────────────────────
    final foldPath = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width - 18, size.height)
      ..lineTo(size.width, size.height - 18)
      ..close();
    canvas.drawPath(foldPath,
        Paint()..color = Colors.black.withOpacity(0.2));
    
    // ── Spiral binding rings on left edge ────────────────────
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final ringFillPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    const ringCount = 7;
    final ringSpacing = size.height / (ringCount + 1);
    for (int i = 1; i <= ringCount; i++) {
      final cy = ringSpacing * i;
      final ringRect = Rect.fromCenter(
          center: Offset(spineWidth / 2, cy),
          width: spineWidth * 1.1,
          height: ringSpacing * 0.38);
      canvas.drawOval(ringRect, ringFillPaint);
      canvas.drawOval(ringRect, ringPaint);
    }

    // ── Subtle vignette overlay ───────────────────────────────
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.18),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(_NotebookCoverPainter old) => false;
}


class _DummyNotebook {
  final String id;
  final String title;
  final int pageCount;
  _DummyNotebook(
      {required this.id, required this.title, required this.pageCount});
}
