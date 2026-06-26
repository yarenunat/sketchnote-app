import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../canvas/viewmodels/canvas_viewmodel.dart';
import '../../canvas/engine/brushes/brush_settings.dart';

class BrushLibrarySheet extends ConsumerWidget {
  final String pageId;

  const BrushLibrarySheet({super.key, required this.pageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(canvasViewModelProvider(pageId));

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Brush Library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: BrushPresets.defaults.length,
              itemBuilder: (context, index) {
                final brush = BrushPresets.defaults[index];
                final isActive = stateAsync.value?.activeBrush.id == brush.id;
                
                return ListTile(
                  leading: Icon(Icons.brush, color: isActive ? Colors.blue : Colors.grey),
                  title: Text(brush.name, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                  subtitle: Text('Size: ${brush.baseSize.toStringAsFixed(1)}'),
                  trailing: isActive ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    ref.read(canvasViewModelProvider(pageId).notifier).selectBrush(brush);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
