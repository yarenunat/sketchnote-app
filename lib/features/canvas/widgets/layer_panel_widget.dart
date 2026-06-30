import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/layer_model.dart';
import '../viewmodels/canvas_viewmodel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/extensions/app_extensions.dart';

/// A slide-in side panel showing all layers for the current page.
///
/// Features:
///  - List of layers (name, visibility toggle, opacity slider, active highlight)
///  - Drag-to-reorder via ReorderableListView
///  - Add/delete layer buttons
///  - Flatten all layers
///  - Tap to select active layer
class LayerPanelWidget extends ConsumerWidget {
  const LayerPanelWidget({
    super.key,
    required this.pageId,
  });

  final String pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(canvasViewModelProvider(pageId));

    return stateAsync.when(
      data: (state) => _buildPanel(context, ref, state),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPanel(BuildContext context, WidgetRef ref, CanvasState state) {
    final vm = ref.read(canvasViewModelProvider(pageId).notifier);
    final isDark = context.isDark;
    final bg = isDark ? AppColors.darkSurface : AppColors.warmWhite;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.warmGray100;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 8, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Layers',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: isDark ? AppColors.darkPrimary : AppColors.inkBlack,
                  ),
                ),
                const Spacer(),
                // Add layer
                _PanelIconButton(
                  icon: Icons.add,
                  tooltip: 'New Layer',
                  onTap: state.layers.length < 10 ? vm.addLayer : null,
                ),
                const SizedBox(width: 4),
                // Flatten
                _PanelIconButton(
                  icon: Icons.layers_clear,
                  tooltip: 'Flatten All Layers',
                  onTap: state.layers.length > 1 ? vm.flattenLayers : null,
                ),
                const SizedBox(width: 4),
                // Close panel
                _PanelIconButton(
                  icon: Icons.close,
                  tooltip: 'Close',
                  onTap: vm.toggleLayerPanel,
                ),
              ],
            ),
          ),

          // ── Layer Count ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  size: 14,
                  color: isDark ? AppColors.darkMuted : AppColors.warmGray500,
                ),
                const SizedBox(width: 6),
                Text(
                  '${state.layers.length} / 10 layers',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkMuted : AppColors.warmGray500,
                  ),
                ),
              ],
            ),
          ),

          // ── Layer List ─────────────────────────────────────────────────
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: state.layers.length,
              onReorder: vm.reorderLayer,
              proxyDecorator: (child, index, animation) => Material(
                color: Colors.transparent,
                child: child,
              ),
              itemBuilder: (context, index) {
                final layer = state.layers[index];
                final isActive = index == state.activeLayerIndex;
                return _LayerTile(
                  key: ValueKey(layer.id),
                  layer: layer,
                  isActive: isActive,
                  isDark: isDark,
                  onTap: () => vm.selectLayer(index),
                  onToggleVisibility: () =>
                      vm.toggleLayerVisibility(layer.id),
                  onDelete: state.layers.length > 1
                      ? () => vm.deleteLayer(layer.id)
                      : null,
                  onOpacityChanged: (v) =>
                      vm.setLayerOpacity(layer.id, v),
                  onRename: (name) => vm.renameLayer(layer.id, name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _LayerTile extends StatefulWidget {
  const _LayerTile({
    super.key,
    required this.layer,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    required this.onToggleVisibility,
    this.onDelete,
    required this.onOpacityChanged,
    required this.onRename,
  });

  final LayerState layer;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onDelete;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<String> onRename;

  @override
  State<_LayerTile> createState() => _LayerTileState();
}

class _LayerTileState extends State<_LayerTile> {
  bool _expanded = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.layer.name);
  }

  @override
  void didUpdateWidget(_LayerTile old) {
    super.didUpdateWidget(old);
    if (old.layer.name != widget.layer.name) {
      _nameController.text = widget.layer.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isDark ? AppColors.darkElevated : AppColors.cream;
    final inactiveColor = widget.isDark ? AppColors.darkSurface : AppColors.warmWhite;
    final textColor = widget.isDark ? AppColors.darkPrimary : AppColors.inkBlack;
    final mutedColor = widget.isDark ? AppColors.darkMuted : AppColors.warmGray500;
    final borderColor = widget.isDark ? AppColors.darkBorder : AppColors.warmGray100;

    return AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: widget.isActive ? activeColor : inactiveColor,
        border: widget.isActive
            ? Border(
                left: BorderSide(
                  color: AppColors.accent,
                  width: 3,
                ),
              )
            : null,
      ),
      child: Column(
        children: [
          // ── Main row ──────────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              widget.onTap();
              setState(() => _expanded = !_expanded && widget.isActive);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Layer thumbnail placeholder
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(
                      Icons.layers,
                      size: 18,
                      color: widget.isActive ? AppColors.accent : mutedColor,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Layer name
                  Expanded(
                    child: Text(
                      widget.layer.name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: widget.isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Visibility toggle
                  GestureDetector(
                    onTap: widget.onToggleVisibility,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        widget.layer.isVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: widget.layer.isVisible ? mutedColor : borderColor,
                      ),
                    ),
                  ),

                  // Expand/collapse for options
                  GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: mutedColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded options ──────────────────────────────────────────
          if (_expanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Opacity slider
                  Row(
                    children: [
                      Text('Opacity', style: TextStyle(fontSize: 11, color: mutedColor)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            activeTrackColor: AppColors.accent,
                            inactiveTrackColor: borderColor,
                            thumbColor: AppColors.accent,
                            overlayColor: AppColors.accent.withAlpha(40),
                          ),
                          child: Slider(
                            value: widget.layer.opacity,
                            onChanged: widget.onOpacityChanged,
                            min: 0.0,
                            max: 1.0,
                          ),
                        ),
                      ),
                      Text(
                        '${(widget.layer.opacity * 100).round()}%',
                        style: TextStyle(fontSize: 11, color: mutedColor),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Rename field
                  TextField(
                    controller: _nameController,
                    style: TextStyle(fontSize: 12, color: textColor),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      hintText: 'Layer name',
                      suffix: GestureDetector(
                        onTap: () =>
                            widget.onRename(_nameController.text),
                        child: Icon(Icons.check, size: 14, color: AppColors.accent),
                      ),
                    ),
                    onSubmitted: widget.onRename,
                  ),

                  const SizedBox(height: 6),

                  // Delete button
                  if (widget.onDelete != null)
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline,
                                size: 14, color: AppColors.error),
                            const SizedBox(width: 6),
                            Text(
                              'Delete Layer',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(color: borderColor, height: 1),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PanelIconButton extends StatelessWidget {
  const _PanelIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: onTap != null
                ? Colors.transparent
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null
                ? (isDark ? AppColors.darkSecondary : AppColors.warmGray700)
                : (isDark ? AppColors.darkBorder : AppColors.warmGray300),
          ),
        ),
      ),
    );
  }
}
