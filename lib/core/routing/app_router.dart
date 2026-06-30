import 'package:flutter/material.dart';

import '../../features/library/views/library_screen.dart';
import '../../features/notebook/views/notebook_pager_screen.dart';
import '../../features/canvas/views/canvas_view.dart';
import '../../features/settings/views/settings_screen.dart';

/// Named route constants for the app.
class AppRoutes {
  AppRoutes._();

  static const String library = '/';
  static const String notebook = '/notebook';
  static const String canvas = '/canvas';
  static const String settings = '/settings';
}

/// Central route map for [MaterialApp.routes].
///
/// Use [Navigator.pushNamed] with the route name and
/// pass required arguments via [RouteSettings.arguments].
class AppRouter {
  AppRouter._();

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.library: (_) => const LibraryScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      };

  /// Handles routes that require arguments (e.g. notebookId, pageId).
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.notebook:
        final notebookId = settings.arguments as String;
        return _buildPageRoute(
          settings: settings,
          child: NotebookPagerScreen(notebookId: notebookId),
        );

      case AppRoutes.canvas:
        final pageId = settings.arguments as String;
        return _buildPageRoute(
          settings: settings,
          child: Scaffold(
            body: CanvasView(pageId: pageId),
          ),
        );

      default:
        return null;
    }
  }

  static PageRoute<T> _buildPageRoute<T>({
    required RouteSettings settings,
    required Widget child,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth fade + slide-up transition
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}
