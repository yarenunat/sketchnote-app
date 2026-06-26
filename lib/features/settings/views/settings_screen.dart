import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final vm = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          SwitchListTile(
            title: const Text('Left-Handed Mode'),
            subtitle: const Text('Moves the toolbar to the left side of the screen.'),
            value: state.isLeftHandedMode,
            onChanged: (val) {
              vm.toggleHandedness();
            },
          ),
          ListTile(
            title: const Text('Apple Pencil Double-Tap'),
            subtitle: const Text('Choose what happens when you double-tap the Apple Pencil.'),
            trailing: DropdownButton<PencilDoubleTapAction>(
              value: state.doubleTapAction,
              items: const [
                DropdownMenuItem(value: PencilDoubleTapAction.switchToEraser, child: Text('Switch to Eraser')),
                DropdownMenuItem(value: PencilDoubleTapAction.undo, child: Text('Undo')),
                DropdownMenuItem(value: PencilDoubleTapAction.showColorPicker, child: Text('Show Color Picker')),
                DropdownMenuItem(value: PencilDoubleTapAction.none, child: Text('None')),
              ],
              onChanged: (val) {
                if (val != null) {
                  vm.setDoubleTapAction(val);
                }
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Storage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Local Cache', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Cache'),
                  content: const Text('Are you sure you want to clear the local cache? This will not delete your notebooks.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache cleared.')));
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          const ListTile(
            title: Text('SketchNote App'),
            subtitle: Text('Version 0.1.0\nProfessional stylus-first sketching & note-taking app.'),
          ),
        ],
      ),
    );
  }
}
