import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A gesture-driven 3D page-curl / page-flip widget.
///
/// Mimics the feel of turning a physical notebook page:
///   - The user drags from the RIGHT edge → the page curls back to reveal
///     the next page underneath.
///   - Release past 50% → spring-complete the flip ([onFlipForward] called).
///   - Release before 50% → snap back to current page.
///   - Supports left→right swipe to go backwards if [allowBackwardFlip]=true.
///
/// Usage:
/// ```dart
/// PageFlipWidget(
///   currentPage: MyPageWidget(),
///   nextPage: MyNextPageWidget(),
///   previousPage: MyPrevPageWidget(),
///   onFlipForward: () => setState(() => pageIndex++),
///   onFlipBackward: () => setState(() => pageIndex--),
/// )
/// ```
///
/// Performance: all page widgets are wrapped in [RepaintBoundary] so that
/// only the curl overlay is re-painted each frame, not the page content.
class PageFlipWidget extends StatefulWidget {
  const PageFlipWidget({
    super.key,
    required this.currentPage,
    required this.nextPage,
    this.previousPage,
    required this.onFlipForward,
    this.onFlipBackward,
    this.allowBackwardFlip = true,
    /// Width of the drag-sensitive edge zone (in logical pixels).
    this.edgeSensitivity = 72.0,
    this.pageShadowColor = const Color(0x55000000),
    this.pageBackColor = const Color(0xFFF0EBE0),
  });

  final Widget currentPage;
  final Widget nextPage;
  final Widget? previousPage;
  final VoidCallback onFlipForward;
  final VoidCallback? onFlipBackward;
  final bool allowBackwardFlip;
  final double edgeSensitivity;
  final Color pageShadowColor;
  final Color pageBackColor;

  @override
  State<PageFlipWidget> createState() => _PageFlipWidgetState();
}

enum _FlipDirection { forward, backward }

class _PageFlipWidgetState extends State<PageFlipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  _FlipDirection _direction = _FlipDirection.forward;

  /// 0.0 = page fully visible, 1.0 = page fully flipped.
  double _dragProgress = 0.0;

  /// The finger's raw offset on the page (used for realistic curl origin).
  Offset _dragPosition = Offset.zero;

  bool _isDragging = false;
  bool _gestureStartedInZone = false;
  late Size _pageSize;

  static const double _completionThreshold = 0.40;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _animation = _controller.view;
    _animation.addListener(_onAnimationTick);
    _animation.addStatusListener(_onAnimationStatus);
  }

  void _onAnimationTick() {
    if (!_isDragging) {
      setState(() {
        _dragProgress = _animation.value;
      });
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_dragProgress > 0.9) {
        if (_direction == _FlipDirection.forward) {
          widget.onFlipForward();
        } else {
          widget.onFlipBackward?.call();
        }
      }
      // Reset state after callback has triggered (parent will rebuild)
      _controller.reset();
      setState(() {
        _dragProgress = 0.0;
        _isDragging = false;
      });
    } else if (status == AnimationStatus.dismissed) {
      setState(() {
        _dragProgress = 0.0;
        _isDragging = false;
      });
    }
  }

  // ── Gesture handlers ────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails details) {
    if (_controller.isAnimating) return;

    final x = details.localPosition.dx;
    final width = _pageSize.width;

    // Forward flip: start near right edge
    final nearRightEdge = x > width - widget.edgeSensitivity;
    // Backward flip: start near left edge
    final nearLeftEdge = x < widget.edgeSensitivity;

    if (nearRightEdge) {
      _direction = _FlipDirection.forward;
      _gestureStartedInZone = true;
    } else if (nearLeftEdge && widget.allowBackwardFlip && widget.previousPage != null) {
      _direction = _FlipDirection.backward;
      _gestureStartedInZone = true;
    } else {
      _gestureStartedInZone = false;
      return;
    }

    setState(() {
      _isDragging = true;
      _dragPosition = details.localPosition;
      _dragProgress = 0.0;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_gestureStartedInZone || _controller.isAnimating) return;

    final width = _pageSize.width;
    double delta;
    if (_direction == _FlipDirection.forward) {
      // Dragging left → flip forward
      delta = -details.delta.dx / width;
    } else {
      // Dragging right → flip backward
      delta = details.delta.dx / width;
    }

    setState(() {
      _dragProgress = (_dragProgress + delta).clamp(0.0, 1.0);
      _dragPosition = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_gestureStartedInZone) return;
    _isDragging = false;

    if (_dragProgress >= _completionThreshold) {
      // Complete the flip
      _animation = Tween<double>(begin: _dragProgress, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      )
        ..addListener(_onAnimationTick)
        ..addStatusListener(_onAnimationStatus);
      _controller
        ..reset()
        ..forward();
    } else {
      // Snap back
      _animation = Tween<double>(begin: _dragProgress, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      )
        ..addListener(_onAnimationTick)
        ..addStatusListener(_onAnimationStatus);
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _pageSize = Size(constraints.maxWidth, constraints.maxHeight);

        final isActive = _dragProgress > 0.001;
        final showPrevious = _direction == _FlipDirection.backward && isActive;

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // ── Layer 0: Underneath page ───────────────────────────────
              // When flipping forward: show next page underneath
              // When flipping backward: show current page underneath
              Positioned.fill(
                child: RepaintBoundary(
                  child: showPrevious
                      ? (widget.previousPage ?? widget.currentPage)
                      : widget.nextPage,
                ),
              ),

              // ── Layer 1: Current page (being lifted) ────────────────────
              if (!showPrevious || _direction == _FlipDirection.forward)
                Positioned.fill(
                  child: isActive
                      ? _buildCurlOverlay(constraints.biggest)
                      : RepaintBoundary(child: widget.currentPage),
                ),

              // ── Layer 2: Curl overlay (only when dragging/animating) ────
              if (isActive && !showPrevious)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PageCurlPainter(
                        progress: _dragProgress,
                        direction: _direction,
                        shadowColor: widget.pageShadowColor,
                        pageBackColor: widget.pageBackColor,
                        dragY: _dragPosition.dy,
                        pageHeight: constraints.maxHeight,
                        pageWidth: constraints.maxWidth,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurlOverlay(Size size) {
    // The current page is clipped to only show the non-curled portion.
    // The curled portion is drawn by _PageCurlPainter.
    final foldX = size.width * (1.0 - _dragProgress);

    return Stack(
      children: [
        // Non-curled left portion of current page
        ClipRect(
          clipper: _LeftClipper(foldX),
          child: RepaintBoundary(child: widget.currentPage),
        ),
      ],
    );
  }
}

/// Clips to everything left of [foldX].
class _LeftClipper extends CustomClipper<Rect> {
  final double foldX;
  const _LeftClipper(this.foldX);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, foldX, size.height);

  @override
  bool shouldReclip(_LeftClipper old) => old.foldX != foldX;
}

// ─────────────────────────────────────────────────────────────────────────────
// Page Curl Painter
// ─────────────────────────────────────────────────────────────────────────────

class _PageCurlPainter extends CustomPainter {
  final double progress;       // 0.0 → 1.0
  final _FlipDirection direction;
  final Color shadowColor;
  final Color pageBackColor;
  final double dragY;          // vertical finger position for curl origin
  final double pageHeight;
  final double pageWidth;

  const _PageCurlPainter({
    required this.progress,
    required this.direction,
    required this.shadowColor,
    required this.pageBackColor,
    required this.dragY,
    required this.pageHeight,
    required this.pageWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.001) return;

    final w = size.width;
    final h = size.height;

    // Fold line x-position (where the page bends)
    final foldX = w * (1.0 - progress);

    // The curled width (from foldX to right edge)
    final curlWidth = w - foldX;

    // ── Draw shadow to the LEFT of the fold line ──────────────────────────
    _drawFoldShadow(canvas, foldX, h, curlWidth);

    // ── Draw the curled page flap ─────────────────────────────────────────
    _drawPageFlap(canvas, foldX, h, curlWidth);

    // ── Draw the fold highlight ────────────────────────────────────────────
    _drawFoldHighlight(canvas, foldX, h);
  }

  void _drawFoldShadow(Canvas canvas, double foldX, double h, double curlWidth) {
    final shadowWidth = math.min(curlWidth * 0.5, 40.0);

    final shadowRect = Rect.fromLTWH(
      foldX - shadowWidth,
      0,
      shadowWidth,
      h,
    );

    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          shadowColor.withAlpha((shadowColor.a * 0.6 * progress).round()),
        ],
      ).createShader(shadowRect);

    canvas.drawRect(shadowRect, shadowPaint);
  }

  void _drawPageFlap(Canvas canvas, double foldX, double h, double curlWidth) {
    // The flap is the mirrored/curled portion — we draw it with perspective.
    // The flap width shrinks as progress increases (the page is curling away).
    // At progress=1.0, flap is a very thin sliver at the left edge.

    final flapWidth = curlWidth * (1.0 - progress * 0.6);

    // Build the flap path — a trapezoid that simulates 3D curl
    final topFold = Offset(foldX, 0.0);
    final bottomFold = Offset(foldX, h);

    // The visible flap (mirrored)
    final topFlapEnd = Offset(foldX - flapWidth, 0.0);
    final bottomFlapEnd = Offset(foldX - flapWidth, h);

    // Perspective squeeze: top and bottom taper slightly
    final perspectiveTaper = h * 0.04 * progress;
    final topFlapEndP = Offset(topFlapEnd.dx + perspectiveTaper, topFlapEnd.dy + perspectiveTaper);
    final bottomFlapEndP = Offset(bottomFlapEnd.dx + perspectiveTaper, bottomFlapEnd.dy - perspectiveTaper);

    final flapPath = Path()
      ..moveTo(topFold.dx, topFold.dy)
      ..lineTo(topFlapEndP.dx, topFlapEndP.dy)
      ..lineTo(bottomFlapEndP.dx, bottomFlapEndP.dy)
      ..lineTo(bottomFold.dx, bottomFold.dy)
      ..close();

    // Draw page back (slightly off-white/warm)
    final backPaint = Paint()
      ..color = pageBackColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(flapPath, backPaint);

    // Draw gradient on the back of the page (darkens toward the fold)
    final gradientRect = Rect.fromLTWH(foldX - flapWidth, 0, flapWidth, h);
    final backGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Colors.black.withAlpha((0.15 * progress * 255).round()),
          Colors.transparent,
        ],
      ).createShader(gradientRect);
    canvas.drawPath(flapPath, backGradient);

    // Cylindrical curl highlight at the left edge of the flap
    final curlHighlightRect = Rect.fromLTWH(
      topFlapEndP.dx,
      topFlapEndP.dy,
      8.0 * (1.0 - progress * 0.5),
      h,
    );
    if (curlHighlightRect.width > 0.5) {
      final curlHighlight = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withAlpha((0.25 * (1.0 - progress) * 255).round()),
            Colors.transparent,
          ],
        ).createShader(curlHighlightRect);
      canvas.drawPath(flapPath, curlHighlight);
    }

    // Original page area (right side, behind the curl) is painted with
    // a gradient to simulate the page bending away from the viewer.
    final behindRect = Rect.fromLTWH(foldX, 0, curlWidth, h);
    final behindGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.black.withAlpha((0.1 * progress * 255).round()),
          Colors.black.withAlpha((0.04 * progress * 255).round()),
        ],
      ).createShader(behindRect);
    canvas.drawRect(behindRect, behindGradient);
  }

  void _drawFoldHighlight(Canvas canvas, double foldX, double h) {
    // Thin bright highlight right at the fold line — simulates specular
    // light on the paper edge.
    final highlightWidth = 3.0 * (1.0 - progress * 0.7);
    if (highlightWidth < 0.5) return;

    final highlightRect = Rect.fromLTWH(foldX, 0, highlightWidth, h);
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withAlpha((0.6 * 255).round()),
          Colors.transparent,
        ],
      ).createShader(highlightRect);
    canvas.drawRect(highlightRect, highlightPaint);
  }

  @override
  bool shouldRepaint(_PageCurlPainter old) =>
      old.progress != progress ||
      old.dragY != dragY ||
      old.direction != direction;
}
