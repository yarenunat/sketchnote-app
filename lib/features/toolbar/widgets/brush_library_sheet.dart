import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../canvas/engine/brushes/brush_settings.dart';
import '../../canvas/viewmodels/canvas_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/app_extensions.dart';

/// A bottom-sheet brush library panel.
class BrushLibrarySheet extends ConsumerWidget {
  const BrushLibrarySheet({super.key, required this.pageId});
  final String pageId;

  static Future<void> show(BuildContext context, String pageId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BrushLibrarySheet(pageId: pageId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(canvasViewModelProvider(pageId));
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.warmWhite;

    return Container(
      height: context.screenHeight * 0.5,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.warmGray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Brushes', style: context.textTheme.headlineSmall),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: stateAsync.when(
              data: (state) {
                final activeBrushId =
                    state.isErasing ? 'eraser_soft' : state.activeBrush.id;
                final brushes = [
                  ...BrushPresets.defaults,
                  BrushPresets.eraser,
                ];
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: brushes.length,
                  itemBuilder: (context, index) {
                    final brush = brushes[index];
                    final isActive = brush.id == activeBrushId;
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(canvasViewModelProvider(pageId).notifier)
                            .selectBrush(brush);
                        Navigator.of(context).pop();
                      },
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent.withAlpha(20)
                              : (isDark ? AppColors.darkElevated : AppColors.cream),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? AppColors.accent
                                : (isDark ? AppColors.darkBorder : AppColors.warmGray100),
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _brushIcon(brush.id),
                              size: 28,
                              color: isActive
                                  ? AppColors.accent
                                  : (isDark ? AppColors.darkSecondary : AppColors.warmGray700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              brush.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                color: isActive
                                    ? AppColors.accent
                                    : (isDark ? AppColors.darkSecondary : AppColors.warmGray700),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _brushIcon(String brushId) {
    switch (brushId) {
      case 'technical_pen':
        return Icons.edit;
      case 'pencil_hb':
        return Icons.border_color;
      case 'marker':
        return Icons.brush;
      case 'watercolor':
        return Icons.water_drop_outlined;
      case 'soft_charcoal':
        return Icons.grain;
      case 'eraser_soft':
        return Icons.cleaning_services_outlined;
      default:
        return Icons.palette_outlined;
    }
  }
}
