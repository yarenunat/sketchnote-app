import 'package:flutter/material.dart';

import '../models/notebook_models.dart';

/// CustomPainter that draws ruled/grid/dot/millimeter paper textures
/// as the page background on the drawing canvas.
///
/// Designed to be drawn once and cached — the caller should wrap this
/// in a [RepaintBoundary] for optimal performance.
class PageBackgroundPainter extends CustomPainter {
  final PageBackgroundType type;
  final Color paperColor;
  final Color lineColor;

  const PageBackgroundPainter({
    required this.type,
    this.paperColor = const Color(0xFFFAF7F2),
    this.lineColor = const Color(0xFFD6CFC5),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = paperColor,
    );

    switch (type) {
      case PageBackgroundType.blank:
        break; // Just the background color
      case PageBackgroundType.lined:
        _drawLined(canvas, size);
        break;
      case PageBackgroundType.grid:
        _drawGrid(canvas, size);
        break;
      case PageBackgroundType.dotted:
        _drawDotted(canvas, size);
        break;
      case PageBackgroundType.millimeter:
        _drawMillimeter(canvas, size);
        break;
    }
  }

  // ── Lined Paper ──────────────────────────────────────────────────────────
  void _drawLined(Canvas canvas, Size size) {
    const lineSpacing = 32.0;
    const marginLeft = 56.0;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8;

    // Red margin line
    canvas.drawLine(
      Offset(marginLeft, 0),
      Offset(marginLeft, size.height),
      Paint()
        ..color = const Color(0xFFE8A0A0)
        ..strokeWidth = 1.0,
    );

    // Horizontal rules
    double y = lineSpacing * 2; // Start after header space
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
      y += lineSpacing;
    }
  }

  // ── Grid Paper ───────────────────────────────────────────────────────────
  void _drawGrid(Canvas canvas, Size size) {
    const spacing = 28.0;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.7;

    // Vertical lines
    double x = spacing;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += spacing;
    }

    // Horizontal lines
    double y = spacing;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += spacing;
    }
  }

  // ── Dotted Paper ─────────────────────────────────────────────────────────
  void _drawDotted(Canvas canvas, Size size) {
    const spacing = 28.0;
    const radius = 1.2;
    final paint = Paint()..color = lineColor;

    double y = spacing;
    while (y < size.height) {
      double x = spacing;
      while (x < size.width) {
        canvas.drawCircle(Offset(x, y), radius, paint);
        x += spacing;
      }
      y += spacing;
    }
  }

  // ── Millimeter Paper ─────────────────────────────────────────────────────
  void _drawMillimeter(Canvas canvas, Size size) {
    const mmPx = 3.78; // 1mm at 96dpi ≈ 3.78px
    const smallSpacing = mmPx;        // 1mm grid
    const mediumSpacing = mmPx * 5;   // 5mm grid
    const largeSpacing = mmPx * 10;   // 1cm grid

    final smallPaint = Paint()
      ..color = lineColor.withAlpha(80)
      ..strokeWidth = 0.4;
    final mediumPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.6;
    final largePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.9;

    // Small 1mm grid
    _drawGridLines(canvas, size, smallSpacing, smallPaint);
    // Medium 5mm grid
    _drawGridLines(canvas, size, mediumSpacing, mediumPaint);
    // Large 1cm grid
    _drawGridLines(canvas, size, largeSpacing, largePaint);
  }

  void _drawGridLines(Canvas canvas, Size size, double spacing, Paint paint) {
    double x = 0;
    while (x <= size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += spacing;
    }
    double y = 0;
    while (y <= size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += spacing;
    }
  }

  @override
  bool shouldRepaint(PageBackgroundPainter old) =>
      old.type != type || old.paperColor != paperColor;
}

/// A small preview widget for the template selector.
class PageTemplatePreview extends StatelessWidget {
  const PageTemplatePreview({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final PageBackgroundType type;
  final bool isSelected;
  final VoidCallback onTap;

  static const Map<PageBackgroundType, String> _labels = {
    PageBackgroundType.blank: 'Blank',
    PageBackgroundType.lined: 'Lined',
    PageBackgroundType.grid: 'Grid',
    PageBackgroundType.dotted: 'Dotted',
    PageBackgroundType.millimeter: 'Millimeter',
  };

  static const Map<PageBackgroundType, IconData> _icons = {
    PageBackgroundType.blank: Icons.crop_portrait,
    PageBackgroundType.lined: Icons.format_line_spacing,
    PageBackgroundType.grid: Icons.grid_on,
    PageBackgroundType.dotted: Icons.grain,
    PageBackgroundType.millimeter: Icons.table_chart_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4845A) : const Color(0xFFD6CFC5),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4845A).withAlpha(50),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              // Preview
              Expanded(
                child: CustomPaint(
                  painter: PageBackgroundPainter(type: type),
                  size: const Size.fromHeight(80),
                  child: Container(),
                ),
              ),
              // Label
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: isSelected
                    ? const Color(0xFFD4845A).withAlpha(20)
                    : Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _icons[type]!,
                      size: 14,
                      color: isSelected
                          ? const Color(0xFFD4845A)
                          : const Color(0xFF8B7B6B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _labels[type]!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? const Color(0xFFD4845A)
                            : const Color(0xFF8B7B6B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
