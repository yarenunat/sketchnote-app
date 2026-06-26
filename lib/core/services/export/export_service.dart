import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/notebook/models/notebook_models.dart';
import '../../../features/canvas/engine/stroke/stroke_builder.dart';
import '../../../features/canvas/engine/input/input_point.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

class ExportService {
  final double _pageWidth = 1200;
  final double _pageHeight = 1600;

  StrokeResult _rebuildStroke(StrokeData data) {
    final builder = StrokeBuilder(brush: data.brush, color: data.color);
    for (final pt in data.points) {
      builder.addPoint(InputPoint(
        position: pt,
        timestamp: Duration.zero,
        kind: ui.PointerDeviceKind.stylus,
        pressure: 1.0,
      ));
    }
    return builder.finish();
  }

  Future<String> exportNotebookAsPdf(Notebook notebook) async {
    final pdfDoc = pw.Document();

    for (final page in notebook.pages) {
      final strokes = page.strokes.map((s) => _rebuildStroke(s)).toList();

      pdfDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(_pageWidth, _pageHeight),
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.CustomPaint(
                size: PdfPoint(_pageWidth, _pageHeight),
                painter: (PdfGraphics canvas, PdfPoint size) {
                  for (final stroke in strokes) {
                    final polygon = stroke.outlinePolygon;
                    if (polygon.isEmpty) continue;

                    canvas.setFillColor(PdfColor.fromInt(stroke.color.toARGB32()));
                    canvas.moveTo(polygon.first.dx, _pageHeight - polygon.first.dy); // PDF y is inverted

                    for (int i = 1; i < polygon.length; i++) {
                      canvas.lineTo(polygon[i].dx, _pageHeight - polygon[i].dy);
                    }
                    canvas.fillPath();
                  }
                },
              ),
            );
          },
        ),
      );
    }

    final bytes = await pdfDoc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/notebook_${notebook.id}.pdf');
    await file.writeAsBytes(bytes);
    
    return file.path;
  }

  Future<String> exportPageAsImage(NotebookPage page, {double pixelRatio = 3.0}) async {
    final strokes = page.strokes.map((s) => _rebuildStroke(s)).toList();
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    canvas.scale(pixelRatio);
    canvas.drawRect(Rect.fromLTWH(0, 0, _pageWidth, _pageHeight), Paint()..color = Colors.white);
    
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..style = PaintingStyle.fill
        ..blendMode = stroke.brushSnapshot.blendMode;
      canvas.drawPath(stroke.path, paint);
    }
    
    final picture = recorder.endRecording();
    final img = await picture.toImage((_pageWidth * pixelRatio).toInt(), (_pageHeight * pixelRatio).toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/page_${page.id}.png');
    await file.writeAsBytes(bytes);
    
    return file.path;
  }
}
