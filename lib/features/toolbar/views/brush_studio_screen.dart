import 'dart:ui';
import 'package:flutter/material.dart';

import '../../canvas/engine/brushes/brush_settings.dart';
import '../../canvas/engine/input/input_point.dart';
import '../../canvas/engine/stroke/stroke_builder.dart';

class BrushStudioScreen extends StatefulWidget {
  final BrushSettings initialBrush;

  const BrushStudioScreen({super.key, required this.initialBrush});

  @override
  State<BrushStudioScreen> createState() => _BrushStudioScreenState();
}

class _BrushStudioScreenState extends State<BrushStudioScreen> {
  late BrushSettings _draftBrush;

  @override
  void initState() {
    super.initState();
    _draftBrush = widget.initialBrush.copyWith();
  }

  void _updateBrush(BrushSettings newBrush) {
    setState(() {
      _draftBrush = newBrush;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brush Studio'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _draftBrush),
            child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.shade50,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSlider('Base Size', _draftBrush.baseSize, 1.0, 50.0, (val) => _updateBrush(_draftBrush.copyWith(baseSize: val))),
                  _buildSlider('Base Opacity', _draftBrush.baseOpacity, 0.0, 1.0, (val) => _updateBrush(_draftBrush.copyWith(baseOpacity: val))),
                  const Divider(),
                  _buildSlider('Pressure to Size Curve', _draftBrush.pressureToSizeCurve, 0.0, 1.0, (val) => _updateBrush(_draftBrush.copyWith(pressureToSizeCurve: val))),
                  _buildSlider('Pressure to Opacity Curve', _draftBrush.pressureToOpacityCurve, 0.0, 1.0, (val) => _updateBrush(_draftBrush.copyWith(pressureToOpacityCurve: val))),
                  const Divider(),
                  _buildSlider('Stabilization', _draftBrush.stabilization, 0.0, 0.99, (val) => _updateBrush(_draftBrush.copyWith(stabilization: val))),
                  _buildSlider('Start Taper', _draftBrush.taperStart, 0.0, 1.0, (val) => _updateBrush(_draftBrush.copyWith(taperStart: val))),
                  _buildSlider('End Taper', _draftBrush.taperEnd, 0.0, 1.0, (val) => _updateBrush(_draftBrush.copyWith(taperEnd: val))),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: _LivePreviewPad(brush: _draftBrush),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _LivePreviewPad extends StatelessWidget {
  final BrushSettings brush;

  const _LivePreviewPad({required this.brush});

  @override
  Widget build(BuildContext context) {
    final builder = StrokeBuilder(brush: brush, color: Colors.black);
    
    // Simulate a cursive "S" curve with varying pressure
    final points = [
      InputPoint(position: const Offset(100, 100), timestamp: Duration.zero, kind: PointerDeviceKind.stylus, pressure: 0.1),
      InputPoint(position: const Offset(150, 80), timestamp: Duration.zero, kind: PointerDeviceKind.stylus, pressure: 0.3),
      InputPoint(position: const Offset(200, 120), timestamp: Duration.zero, kind: PointerDeviceKind.stylus, pressure: 0.8),
      InputPoint(position: const Offset(150, 200), timestamp: Duration.zero, kind: PointerDeviceKind.stylus, pressure: 1.0),
      InputPoint(position: const Offset(100, 250), timestamp: Duration.zero, kind: PointerDeviceKind.stylus, pressure: 0.5),
      InputPoint(position: const Offset(180, 300), timestamp: Duration.zero, kind: PointerDeviceKind.stylus, pressure: 0.1),
    ];
    
    // add highly interpolated points
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      for (double t = 0; t <= 1.0; t += 0.1) {
        builder.addPoint(InputPoint(
          position: Offset.lerp(p1.position, p2.position, t)!,
          timestamp: Duration.zero,
          kind: PointerDeviceKind.stylus,
          pressure: lerpDouble(p1.pressure, p2.pressure, t)!,
        ));
      }
    }
    
    final result = builder.finish();

    return CustomPaint(
      size: const Size(300, 400),
      painter: _PreviewPainter(result),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  final StrokeResult stroke;
  _PreviewPainter(this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stroke.color.withOpacity(stroke.brushSnapshot.baseOpacity)
      ..style = PaintingStyle.fill
      ..blendMode = stroke.brushSnapshot.blendMode;
    canvas.drawPath(stroke.path, paint);
  }

  @override
  bool shouldRepaint(covariant _PreviewPainter oldDelegate) => true;
}
