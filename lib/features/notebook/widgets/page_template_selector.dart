import 'package:flutter/material.dart';

import '../models/notebook_models.dart';
import '../widgets/page_background_painter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/app_extensions.dart';

/// Modal bottom sheet for selecting a page background template.
///
/// Usage:
/// ```dart
/// PageTemplateSelector.show(
///   context: context,
///   currentType: page.backgroundType,
///   onSelected: (type) => vm.setPageBackground(type),
/// );
/// ```
class PageTemplateSelector extends StatelessWidget {
  const PageTemplateSelector({
    super.key,
    required this.currentType,
    required this.onSelected,
  });

  final PageBackgroundType currentType;
  final ValueChanged<PageBackgroundType> onSelected;

  static Future<void> show({
    required BuildContext context,
    required PageBackgroundType currentType,
    required ValueChanged<PageBackgroundType> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PageTemplateSelector(
        currentType: currentType,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.warmGray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Page Style', style: context.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Choose a background for this page',
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 5,
              shrinkWrap: true,
              childAspectRatio: 0.75,
              physics: const NeverScrollableScrollPhysics(),
              children: PageBackgroundType.values.map((type) {
                return PageTemplatePreview(
                  type: type,
                  isSelected: type == currentType,
                  onTap: () {
                    onSelected(type);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
