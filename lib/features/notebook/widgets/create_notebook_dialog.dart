import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/app_extensions.dart';

/// Dialog for creating a new notebook.
///
/// Collects:
///  - Title
///  - Cover color
///  - (Future: cover texture)
///
/// Usage:
/// ```dart
/// final result = await CreateNotebookDialog.show(context);
/// if (result != null) {
///   vm.createNotebook(title: result.title, coverColorValue: result.colorValue);
/// }
/// ```
class CreateNotebookResult {
  final String title;
  final int coverColorValue;
  CreateNotebookResult({required this.title, required this.coverColorValue});
}

class CreateNotebookDialog extends ConsumerStatefulWidget {
  const CreateNotebookDialog({super.key});

  static Future<CreateNotebookResult?> show(BuildContext context) {
    return showDialog<CreateNotebookResult>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const CreateNotebookDialog(),
    );
  }

  @override
  ConsumerState<CreateNotebookDialog> createState() =>
      _CreateNotebookDialogState();
}

class _CreateNotebookDialogState extends ConsumerState<CreateNotebookDialog> {
  final _titleController = TextEditingController(text: 'New Notebook');
  int _selectedColorIdx = 0;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.warmWhite;
    final selectedColor = AppColors.coverGradients[_selectedColorIdx][0];

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withAlpha(80),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Notebook',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkPrimary : AppColors.inkBlack,
                        ),
                      ),
                      Text(
                        'Create your journal',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Title ─────────────────────────────────────────────────
              Text('Title', style: context.textTheme.labelMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Notebook name...',
                ),
                onSubmitted: (_) => _confirm(context),
              ),

              const SizedBox(height: 24),

              // ── Cover color ───────────────────────────────────────────
              Text('Cover Color', style: context.textTheme.labelMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppColors.coverGradients.length,
                  itemBuilder: (_, i) {
                    final colors = AppColors.coverGradients[i];
                    final isSelected = i == _selectedColorIdx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIdx = i),
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        width: isSelected ? 44 : 36,
                        height: isSelected ? 44 : 36,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.inkBlack,
                                  width: 2.5,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colors[0].withAlpha(80),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ── Buttons ───────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirm(context),
                      child: const Text(
                        'Create Notebook',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(
      CreateNotebookResult(
        title: title,
        coverColorValue: AppColors.coverGradients[_selectedColorIdx][0].toARGB32(),
      ),
    );
  }
}
