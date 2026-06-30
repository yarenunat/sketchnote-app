import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../canvas/viewmodels/canvas_viewmodel.dart';
import '../../canvas/viewmodels/collage_controller.dart';
import '../../canvas/engine/brushes/brush_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/hsv_color_picker_widget.dart';
import '../../../shared/extensions/app_extensions.dart';


class ToolbarView extends ConsumerStatefulWidget {
  final String pageId;
  const ToolbarView({super.key, required this.pageId});

  @override
  ConsumerState<ToolbarView> createState() => _ToolbarViewState();
}

class _ToolbarViewState extends ConsumerState<ToolbarView>
    with SingleTickerProviderStateMixin {
  bool _showSliders = false;

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(canvasViewModelProvider(widget.pageId));

    return stateAsync.when(
      data: (state) {
        final vm = ref.read(canvasViewModelProvider(widget.pageId).notifier);
        final collageCtrl = ref.read(collageControllerProvider(widget.pageId).notifier);

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Thickness & Opacity sliders (collapsible) ─────────────
              AnimatedSize(
                duration: AppDurations.normal,
                curve: Curves.easeInOutCubic,
                child: _showSliders
                    ? _buildSliderPanel(context, vm, state)
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 6),

              // ── Color Row ─────────────────────────────────────────────
              _buildColorRow(context, vm, state),

              const SizedBox(height: 6),

              // ── Tool Row ──────────────────────────────────────────────
              _buildToolRow(context, vm, state, collageCtrl),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ── Color Row ────────────────────────────────────────────────────────────

  Widget _buildColorRow(BuildContext context, CanvasViewModel vm, CanvasState state) {
    return _FloatingPill(
      child: ColorSwatchRow(
        selectedColor: state.activeColor,
        colors: AppColors.defaultPalette,
        onColorTap: (color) {
          vm.selectColor(color);
        },
        onPickerTap: () => HsvColorPicker.show(
          context: context,
          currentColor: state.activeColor,
          recentColors: state.recentColors,
          onColorSelected: vm.selectColor,
        ),
      ),
    );
  }

  // ── Tool Row ─────────────────────────────────────────────────────────────

  Widget _buildToolRow(
    BuildContext context,
    CanvasViewModel vm,
    CanvasState state,
    CollageController collageCtrl,
  ) {
    final activeBrushId = state.isErasing ? 'eraser_soft' : state.activeBrush.id;

    return _FloatingPill(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Technical Pen ──────────────────────────────────────────
          _ToolBtn(
            tooltip: 'Pen',
            icon: Icons.edit,
            isActive: activeBrushId == 'technical_pen',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.technicalPen);
            },
          ),
          // ── Pencil ─────────────────────────────────────────────────
          _ToolBtn(
            tooltip: 'Pencil',
            icon: Icons.border_color,
            isActive: activeBrushId == 'pencil_hb',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.pencil);
            },
          ),
          // ── Marker ─────────────────────────────────────────────────
          _ToolBtn(
            tooltip: 'Marker',
            icon: Icons.brush,
            isActive: activeBrushId == 'marker',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.marker);
            },
          ),
          // ── Watercolor ─────────────────────────────────────────────
          _ToolBtn(
            tooltip: 'Watercolor',
            icon: Icons.water_drop_outlined,
            isActive: activeBrushId == 'watercolor',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.watercolor);
            },
          ),
          // ── Charcoal ───────────────────────────────────────────────
          _ToolBtn(
            tooltip: 'Charcoal',
            icon: Icons.grain,
            isActive: activeBrushId == 'soft_charcoal',
            onTap: () {
              if (state.isErasing) vm.toggleEraser();
              vm.selectBrush(BrushPresets.softCharcoal);
            },
          ),

          _Divider(),

          // ── Eraser ─────────────────────────────────────────────────
          _ToolBtn(
            tooltip: 'Eraser',
            icon: Icons.cleaning_services_outlined,
            isActive: state.isErasing,
            onTap: () {
              if (!state.isErasing) vm.selectBrush(BrushPresets.eraser);
              vm.toggleEraser();
            },
          ),

          _Divider(),

          // ── Thickness/Opacity toggle ───────────────────────────────
          _ToolBtn(
            tooltip: 'Brush Settings',
            icon: Icons.tune,
            isActive: _showSliders,
            onTap: () => setState(() => _showSliders = !_showSliders),
          ),

          // ── Layers ─────────────────────────────────────────────────
          _ToolBtn(
            tooltip: 'Layers',
            icon: Icons.layers_outlined,
            isActive: false,
            onTap: () {
              ref
                  .read(canvasViewModelProvider(widget.pageId).notifier)
                  .toggleLayerPanel();
            },
          ),

          _Divider(),

          // ── Photo/Collage ──────────────────────────────────────────
          _ToolBtn(
            tooltip: 'Add Photo',
            icon: Icons.add_photo_alternate_outlined,
            isActive: false,
            onTap: () => _showPhotoMenu(context, collageCtrl),
          ),
        ],
      ),
    );
  }

  // ── Slider Panel ─────────────────────────────────────────────────────────

  Widget _buildSliderPanel(BuildContext context, CanvasViewModel vm, CanvasState state) {
    final isDark = context.isDark;
    final track = isDark ? AppColors.darkBorder : AppColors.warmGray100;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C222F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Thickness
          _SliderRow(
            icon: Icons.line_weight,
            label: 'Size',
            value: state.activeThickness,
            min: 0.1,
            max: 5.0,
            trackColor: track,
            onChanged: vm.setThickness,
            displayValue: '${(state.activeThickness * state.activeBrush.baseSize).toStringAsFixed(1)}px',
          ),
          const SizedBox(height: 8),
          // Opacity
          _SliderRow(
            icon: Icons.opacity,
            label: 'Opacity',
            value: state.activeOpacity,
            min: 0.05,
            max: 1.0,
            trackColor: track,
            onChanged: vm.setOpacity,
            displayValue: '${(state.activeOpacity * 100).round()}%',
          ),
        ],
      ),
    );
  }

  void _showPhotoMenu(BuildContext context, CollageController collageCtrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.warmGray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                collageCtrl.pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                collageCtrl.pickFromCamera();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingPill extends StatelessWidget {
  const _FloatingPill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C222F) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.tooltip = '',
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          width: 40,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withAlpha(30) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: Colors.white.withAlpha(60), width: 1)
                : null,
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withAlpha(30),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.displayValue,
    required this.trackColor,
  });

  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String displayValue;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 6),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: trackColor,
              thumbColor: Colors.white,
              overlayColor: AppColors.accent.withAlpha(40),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            displayValue,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
