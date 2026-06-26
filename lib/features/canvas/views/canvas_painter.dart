import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../engine/stroke/stroke_builder.dart';

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
      final path = activeStroke!.buildPreviewPath();
      final paint = Paint()
        ..color = activeStroke!.color
        ..style = PaintingStyle.fill
        ..blendMode = activeStroke!.brush.blendMode;
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return true; // We recreate the painter on every frame while drawing.
  }
}
