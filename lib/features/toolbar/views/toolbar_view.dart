import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../canvas/viewmodels/canvas_viewmodel.dart';
import '../widgets/brush_library_sheet.dart';

class ToolbarView extends ConsumerWidget {
  final String pageId;

  const ToolbarView({super.key, required this.pageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasStateAsync = ref.watch(canvasViewModelProvider(pageId));

    return canvasStateAsync.when(
      data: (state) {
        final vm = ref.read(canvasViewModelProvider(pageId).notifier);
        
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: const Color(0xE6FFFFFF), // Semi-transparent white
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.brush),
                  color: state.isErasing ? Colors.grey : Colors.blue,
                  tooltip: 'Brush Library',
                  onPressed: () {
                    if (state.isErasing) vm.toggleEraser();
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => BrushLibrarySheet(pageId: pageId),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cleaning_services), // Eraser
                  color: state.isErasing ? Colors.blue : Colors.grey,
                  tooltip: 'Eraser',
                  onPressed: () {
                    vm.toggleEraser();
                  },
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                GestureDetector(
                  onTap: () => _showColorPicker(context, vm, state.activeColor),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: state.activeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 24, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: state.undoStack.isNotEmpty ? vm.undo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: state.redoStack.isNotEmpty ? vm.redo : null,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showColorPicker(BuildContext context, CanvasViewModel vm, Color currentColor) {
    final colors = [
      Colors.black, Colors.red, Colors.green, Colors.blue,
      Colors.orange, Colors.purple, Colors.teal, Colors.brown,
    ];
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) => GestureDetector(
            onTap: () {
              vm.selectColor(c);
              Navigator.pop(context);
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(color: c == currentColor ? Colors.blue : Colors.transparent, width: 3),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
}
