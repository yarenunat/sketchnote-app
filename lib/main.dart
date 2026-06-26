import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/canvas/views/canvas_view.dart';

/// Entry point.
///
/// Cursor TODO: wrap with any startup initialization (database open,
/// shared_preferences load, license checks, etc.) before runApp.
void main() {
  runApp(const ProviderScope(child: SketchNoteApp()));
}

class SketchNoteApp extends StatelessWidget {
  const SketchNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SketchNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const CanvasView(pageId: 'test_page_1'),
    );
  }
}
