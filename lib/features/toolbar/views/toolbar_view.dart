import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../canvas/viewmodels/canvas_viewmodel.dart';
import '../../canvas/engine/brushes/brush_settings.dart';
import '../widgets/brush_library_sheet.dart';

// Paper app color palette for the bottom toolbar
const _paperColors = [
  Color(0xFFE8504A), // Red
  Color(0xFFE8913A), // Orange  
  Color(0xFFE5D55B), // Yellow
  Color(0xFF2DB09A), // Teal
  Color(0xFF3B7BD9), // Blue
  Color(0xFF1A1A1A), // Black
];

class ToolbarView extends ConsumerWidget {
  final String pageId;

  const ToolbarView({super.key, required this.pageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasStateAsync = ref.watch(canvasViewModelProvider(pageId));

    return canvasStateAsync.when(
      data: (state) {
        final vm = ref.read(canvasViewModelProvider(pageId).notifier);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Color Row ──────────────────────────────────────────
            _buildColorRow(context, vm, state),
            const SizedBox(height: 8),
            // ── Tool Row ──────────────────────────────────────────
            _buildToolRow(context, vm, state),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildColorRow(BuildContext context, CanvasViewModel vm, dynamic state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222F),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add color button
          GestureDetector(
            onTap: () => _showColorPicker(context, vm, state.activeColor),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A3145),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 10),
          // Color swatches
          ..._paperColors.map((color) {
            final isActive = (state.activeColor.value == color.value) && !state.isErasing;
            return GestureDetector(
              onTap: () {
                vm.selectColor(color);
                if (state.isErasing) vm.toggleEraser();
              },
              child: Container(
                width: isActive ? 30 : 26,
                height: isActive ? 30 : 26,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: isActive
                      ? Border.all(color: Colors.white, width: 2.5)
                      : null,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius: 8)
                        ]
                      : null,
                ),
              ),
            );
          }).toList(),
          const SizedBox(width: 10),
          // Trash icon (clear)
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.delete_outline, color: Colors.white60, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildToolRow(BuildContext context, CanvasViewModel vm, dynamic state) {
    final activeBrushId = state.isErasing ? 'eraser_soft' : state.activeBrush.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C222F),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Technical Pen — clean, sharp lines
          _buildToolButton(
            tooltip: 'Technical Pen',
            child: const Icon(Icons.edit, size: 22),
            isActive: activeBrushId == 'technical_pen',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.technicalPen);
            },
          ),
          const SizedBox(width: 8),
          // Pencil HB — textured, grainy
          _buildToolButton(
            tooltip: 'Pencil',
            child: const Icon(Icons.border_color, size: 22),
            isActive: activeBrushId == 'pencil_hb',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.pencil);
            },
          ),
          const SizedBox(width: 8),
          // Marker — wide, semi-transparent
          _buildToolButton(
            tooltip: 'Marker',
            child: const Icon(Icons.brush, size: 22),
            isActive: activeBrushId == 'marker',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.marker);
            },
          ),
          const SizedBox(width: 8),
          // Watercolor — soft, blended
          _buildToolButton(
            tooltip: 'Watercolor',
            child: const Icon(Icons.water_drop_outlined, size: 22),
            isActive: activeBrushId == 'watercolor',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.watercolor);
            },
          ),
          const SizedBox(width: 8),
          // Eraser
          _buildToolButton(
            tooltip: 'Eraser',
            child: const Icon(Icons.cleaning_services, size: 22),
            isActive: state.isErasing,
            onTap: () {
              if (!state.isErasing) vm.selectBrush(BrushPresets.eraser);
              vm.toggleEraser();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
      {required Widget child,
      required bool isActive,
      required VoidCallback onTap,
      String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: Colors.white.withOpacity(0.4), width: 1)
                : null,
          ),
          child: IconTheme(
            data: IconThemeData(
                color: isActive ? Colors.white : Colors.white54),
            child: child,
          ),
        ),
      ),
    );
  }

  void _showColorPicker(
      BuildContext context, CanvasViewModel vm, Color currentColor) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1C222F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pick Color',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ..._paperColors,
                  Colors.white,
                  Colors.grey,
                  const Color(0xFF8B4513),
                  const Color(0xFF556B2F),
                  Colors.pink,
                  Colors.cyan,
                ]
                    .map((c) => GestureDetector(
                          onTap: () {
                            vm.selectColor(c);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: c == currentColor
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
