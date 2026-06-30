import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../engine/stroke/stroke_builder.dart';
import '../engine/brushes/brush_settings.dart';

class CanvasPainter extends CustomPainter {
  final ui.Picture? backgroundPicture;
  final StrokeBuilder? activeStroke;

  const CanvasPainter({
    this.backgroundPicture,
    this.activeStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundPicture != null) {
      canvas.drawPicture(backgroundPicture!);
    }

    if (activeStroke != null) {
      _paintBrushStroke(canvas, activeStroke!);
    }
  }

  void _paintBrushStroke(Canvas canvas, StrokeBuilder stroke) {
    final path = stroke.buildPreviewPath();
    final brush = stroke.brush;
    final color = stroke.color;

    switch (brush.id) {
      case 'marker':
        // Marker: flat, wide, semi-transparent — like a Copic marker
        final paint = Paint()
          ..color = color.withOpacity(0.45)
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.multiply;
        canvas.drawPath(path, paint);
        break;

      case 'watercolor':
        // Watercolor: multiple soft passes with low opacity
        for (int i = 0; i < 3; i++) {
          final paint = Paint()
            ..color = color.withOpacity(0.08 + i * 0.04)
            ..style = PaintingStyle.fill
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0 + i * 2.0)
            ..blendMode = BlendMode.srcOver;
          canvas.drawPath(path, paint);
        }
        // Hard edge inner stroke
        final innerPaint = Paint()
          ..color = color.withOpacity(0.12)
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.srcOver;
        canvas.drawPath(path, innerPaint);
        break;

      case 'eraser_soft':
        // Eraser: clear blend mode
        final paint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.clear;
        canvas.drawPath(path, paint);
        break;

      case 'pencil_hb':
        // Pencil: scratchy, semi-transparent, textured feel
        // Draw main stroke with slight transparency
        final mainPaint = Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.fill
          ..blendMode = BlendMode.srcOver;
        canvas.drawPath(path, mainPaint);
        // Add grain texture by drawing tiny dots along path
        _drawPencilGrain(canvas, stroke, color);
        break;

      case 'technical_pen':
      default:
        // Technical pen / default: clean, opaque, sharp
        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..blendMode = brush.blendMode;
        canvas.drawPath(path, paint);
        break;
    }
  }

  void _drawPencilGrain(Canvas canvas, StrokeBuilder stroke, Color color) {
    // Add random scatter dots for pencil grain texture
    final rng = Random(42);
    final bounds = stroke.buildPreviewPath().getBounds();
    final grainPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = bounds.left + rng.nextDouble() * bounds.width;
      final y = bounds.top + rng.nextDouble() * bounds.height;
      canvas.drawCircle(Offset(x, y), 0.5 + rng.nextDouble() * 1.0, grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}
