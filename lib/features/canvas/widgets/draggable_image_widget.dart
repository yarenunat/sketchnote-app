import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/collage_model.dart';
import '../../../core/theme/app_theme.dart';

/// A draggable, scalable, rotatable image widget for the collage layer.
///
/// Supports:
///  - Single-finger pan to drag
///  - Two-finger pinch to scale
///  - Two-finger rotate to rotate
///  - Selection ring with corner handles
///  - Delete button when selected
class DraggableImageWidget extends StatefulWidget {
  const DraggableImageWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onSelect,
    required this.onUpdate,
    required this.onDelete,
    required this.onBringToFront,
  });

  final CollageItem item;
  final bool isSelected;
  final VoidCallback onSelect;
  final void Function({Offset? position, double? scale, double? rotation}) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;

  @override
  State<DraggableImageWidget> createState() => _DraggableImageWidgetState();
}

class _DraggableImageWidgetState extends State<DraggableImageWidget>
    with SingleTickerProviderStateMixin {
  // Gesture state
  Offset _startPosition = Offset.zero;
  double _startScale = 1.0;
  double _startRotation = 0.0;

  // Animation for selection ring appearance
  late AnimationController _selectionAnim;
  late Animation<double> _selectionScale;

  @override
  void initState() {
    super.initState();
    _selectionAnim = AnimationController(
      vsync: this,
      duration: AppDurations.fast,
    );
    _selectionScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _selectionAnim, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(DraggableImageWidget old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _selectionAnim.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _selectionAnim.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    widget.onSelect();
    widget.onBringToFront();
    _startPosition = widget.item.position;
    _startScale = widget.item.scale;
    _startRotation = widget.item.rotation;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    // Pan: move with focal point delta
    final newPosition = _startPosition + details.focalPointDelta;

    // Scale: multiply starting scale by gesture scale
    final newScale = (_startScale * details.scale).clamp(0.1, 10.0);

    // Rotation: add rotation delta
    final newRotation = _startRotation + details.rotation;

    widget.onUpdate(
      position: newPosition,
      scale: newScale,
      rotation: newRotation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayW = widget.item.size.width * widget.item.scale;
    final displayH = widget.item.size.height * widget.item.scale;

    return Positioned(
      left: widget.item.position.dx - displayW / 2,
      top: widget.item.position.dy - displayH / 2,
      width: displayW,
      height: displayH,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onTap: () {
          widget.onSelect();
          widget.onBringToFront();
        },
        child: Transform.rotate(
          angle: widget.item.rotation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Image ────────────────────────────────────────────
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    widget.item.imageFile,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  ),
                ),
              ),

              // ── Selection ring ───────────────────────────────────
              if (widget.isSelected) ...[
                AnimatedBuilder(
                  animation: _selectionScale,
                  builder: (_, child) => Transform.scale(
                    scale: _selectionScale.value,
                    child: child,
                  ),
                  child: Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Corner handles ───────────────────────────────────
                ..._buildCornerHandles(displayW, displayH),

                // ── Delete button (top-right) ────────────────────────
                Positioned(
                  top: -18,
                  right: -18,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerHandles(double w, double h) {
    const handleSize = 14.0;
    const offset = -handleSize / 2;

    return [
      Positioned(left: offset, top: offset, child: _CornerHandle()),
      Positioned(right: offset, top: offset, child: _CornerHandle()),
      Positioned(left: offset, bottom: offset, child: _CornerHandle()),
      Positioned(right: offset, bottom: offset, child: _CornerHandle()),
    ];
  }
}

class _CornerHandle extends StatelessWidget {
  const _CornerHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
