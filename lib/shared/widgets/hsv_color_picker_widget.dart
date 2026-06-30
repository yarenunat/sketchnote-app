import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../extensions/app_extensions.dart';
import '../../core/theme/app_theme.dart';

/// A premium HSV color picker bottom sheet.
///
/// Shows:
///  - HSV color spectrum picker
///  - Hex input field
///  - Opacity slider
///  - Recent colors (up to 10)
///  - Quick palette swatches
///
/// Usage:
/// ```dart
/// HsvColorPicker.show(
///   context: context,
///   currentColor: activeColor,
///   onColorSelected: (color) => vm.selectColor(color),
/// );
/// ```
class HsvColorPicker extends StatefulWidget {
  const HsvColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
    this.recentColors = const [],
  });

  final Color currentColor;
  final ValueChanged<Color> onColorSelected;
  final List<Color> recentColors;

  static Future<void> show({
    required BuildContext context,
    required Color currentColor,
    required ValueChanged<Color> onColorSelected,
    List<Color> recentColors = const [],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HsvColorPicker(
        currentColor: currentColor,
        onColorSelected: onColorSelected,
        recentColors: recentColors,
      ),
    );
  }

  @override
  State<HsvColorPicker> createState() => _HsvColorPickerState();
}

class _HsvColorPickerState extends State<HsvColorPicker> {
  late Color _currentColor;
  late TextEditingController _hexController;
  bool _hexError = false;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.currentColor;
    _hexController = TextEditingController(text: _currentColor.toHex());
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateColor(Color color) {
    setState(() {
      _currentColor = color;
      _hexController.text = color.toHex();
      _hexError = false;
    });
  }

  void _onHexSubmit(String value) {
    try {
      final color = ColorX.fromHex(value);
      _updateColor(color);
    } catch (_) {
      setState(() => _hexError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.warmWhite;
    final handleColor = isDark ? AppColors.darkBorder : AppColors.warmGray300;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Color',
                    style: context.textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  // Preview swatch
                  AnimatedContainer(
                    duration: AppDurations.fast,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.warmGray100,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _currentColor.withAlpha(100),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── HSV Picker ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 200,
                child: ColorPickerArea(
                  HSVColor.fromColor(_currentColor),
                  (hsv) => _updateColor(hsv.toColor()),
                  PaletteType.hsv,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Hue Slider ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 28,
                child: ColorPickerSlider(
                  TrackType.hue,
                  HSVColor.fromColor(_currentColor),
                  (hsv) => _updateColor(hsv.toColor()),
                  displayThumbColor: true,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Opacity Slider ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: 28,
                child: ColorPickerSlider(
                  TrackType.alpha,
                  HSVColor.fromColor(_currentColor),
                  (hsv) => _updateColor(hsv.toColor()),
                  displayThumbColor: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Hex Input ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      decoration: InputDecoration(
                        labelText: 'Hex',
                        prefixText: '#',
                        errorText: _hexError ? 'Invalid hex color' : null,
                        prefixStyle: TextStyle(
                          color: isDark ? AppColors.darkSecondary : AppColors.warmGray500,
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onSubmitted: _onHexSubmit,
                      onEditingComplete: () => _onHexSubmit(_hexController.text),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Quick palette ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Colors',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.darkMuted : AppColors.warmGray500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppColors.defaultPalette.map((color) {
                      final isSelected = _currentColor.toARGB32() == color.toARGB32();
                      return GestureDetector(
                        onTap: () => _updateColor(color),
                        child: AnimatedContainer(
                          duration: AppDurations.fast,
                          width: isSelected ? 36 : 30,
                          height: isSelected ? 36 : 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: isDark ? Colors.white : AppColors.inkBlack,
                                    width: 2.5,
                                  )
                                : Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.warmGray100,
                                    width: 1,
                                  ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withAlpha(100),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: color == Colors.white
                              ? Icon(
                                  Icons.check,
                                  size: isSelected ? 18 : 14,
                                  color: isSelected ? AppColors.inkBlack : Colors.transparent,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // ── Recent colors ─────────────────────────────────────────────
            if (widget.recentColors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: isDark ? AppColors.darkMuted : AppColors.warmGray500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: widget.recentColors
                          .take(10)
                          .map(
                            (color) => GestureDetector(
                              onTap: () => _updateColor(color),
                              child: Container(
                                width: 28,
                                height: 28,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.warmGray100,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Confirm button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentColor,
                    foregroundColor: _currentColor.contrastColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    widget.onColorSelected(_currentColor);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Apply Color',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: _currentColor.contrastColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// A simple color dot row for use in compact toolbars.
class ColorSwatchRow extends StatelessWidget {
  const ColorSwatchRow({
    super.key,
    required this.selectedColor,
    required this.onColorTap,
    required this.onPickerTap,
    this.colors = AppColors.defaultPalette,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorTap;
  final VoidCallback onPickerTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom color button
        GestureDetector(
          onTap: onPickerTap,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: List.generate(
                  12,
                  (i) => HSVColor.fromAHSV(1.0, i * 30.0, 1.0, 1.0).toColor(),
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.add, size: 14, color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(width: 6),
        ...colors.map((color) {
          final isSelected = selectedColor.toARGB32() == color.toARGB32();
          return GestureDetector(
            onTap: () => onColorTap(color),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              curve: Curves.easeOutCubic,
              width: isSelected ? 30 : 26,
              height: isSelected ? 30 : 26,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2.5)
                    : Border.all(
                        color: Colors.white.withAlpha(30),
                        width: 1,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withAlpha(120),
                          blurRadius: 8,
                        )
                      ]
                    : null,
              ),
            ),
          );
        }),
      ],
    );
  }
}
