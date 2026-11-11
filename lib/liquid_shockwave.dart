import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Predefined edge or position for the shockwave origin.
enum ShockwaveSide {
  top,
  bottom,
  left,
  right,
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// A container widget that wraps any arbitrary child and renders a liquid
/// shockwave refraction distortion with chromatic aberration and specular highlights,
/// mimicking the Apple iOS NameDrop / Tap-to-Share liquid wave effect.
///
/// Driven by a snapshot strategy and an Impeller/Skia compatible FragmentShader.
class LiquidShockwaveContainer extends StatefulWidget {
  /// The target child widget to wrap and distort.
  final Widget child;

  /// Total duration of the shockwave ripple animation. Defaults to 650ms.
  final Duration duration;

  /// Easing curve for the shockwave progress. Defaults to [Curves.easeOutCubic].
  final Curve curve;

  /// If true, tapping anywhere on this widget will trigger a shockwave originating
  /// from the user's touch location.
  final bool triggerOnTap;

  /// Default edge or side used when [LiquidShockwaveContainerState.trigger] is called
  /// without an explicit origin. Defaults to [ShockwaveSide.top].
  final ShockwaveSide defaultSide;

  /// The asset path to the compiled FragmentShader.
  final String shaderAsset;

  /// Optional callback invoked when the distortion animation changes status.
  final ValueChanged<AnimationStatus>? onAnimationStatusChanged;

  /// If true, the container will continuously sample the child widget in real-time
  /// on every frame during the shockwave animation, allowing live animations (such as
  /// spinning GIFs, videos, or continuous progress bars) to keep moving WHILE being distorted.
  ///
  /// If false (default), it captures a single high-performance snapshot on trigger.
  final bool liveSampling;

  const LiquidShockwaveContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 650),
    this.curve = Curves.easeOutCubic,
    this.triggerOnTap = false,
    this.defaultSide = ShockwaveSide.top,
    this.shaderAsset = 'shaders/liquid_shockwave.frag',
    this.onAnimationStatusChanged,
    this.liveSampling = false,
  });

  @override
  State<LiquidShockwaveContainer> createState() =>
      LiquidShockwaveContainerState();
}

class LiquidShockwaveContainerState extends State<LiquidShockwaveContainer>
    with SingleTickerProviderStateMixin {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  late final AnimationController _controller;
  late final Animation<double> _animation;

  ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;

  ui.Image? _activeSnapshot;
  Offset _currentOrigin = Offset.zero;

  bool get isReady => _program != null && _shader != null;
  bool get isAnimating => _controller.isAnimating;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _controller.addStatusListener(_handleAnimationStatus);
    _controller.addListener(_handleAnimationTick);

    _loadShader();
  }

  @override
  void didUpdateWidget(covariant LiquidShockwaveContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.shaderAsset != widget.shaderAsset) {
      _loadShader();
    }
  }

  Future<void> _loadShader() async {
    try {
      _program = await ui.FragmentProgram.fromAsset(widget.shaderAsset);
      _shader?.dispose();
      _shader = _program?.fragmentShader();
      if (mounted) setState(() {});
    } catch (e) {
      // Fallback for when used inside a package module
      try {
        _program = await ui.FragmentProgram.fromAsset(
          'packages/liquid_shockwave/${widget.shaderAsset}',
        );
        _shader?.dispose();
        _shader = _program?.fragmentShader();
        if (mounted) setState(() {});
      } catch (fallbackError) {
        debugPrint(
          'LiquidShockwaveContainer: Failed to load shader "${widget.shaderAsset}": '
          '$e (fallback error: $fallbackError)',
        );
      }
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    widget.onAnimationStatusChanged?.call(status);
    // Only clean up when animation reaches full completion
    if (status == AnimationStatus.completed) {
      _cleanupSnapshot();
    }
  }

  void _cleanupSnapshot() {
    if (_activeSnapshot != null) {
      _activeSnapshot!.dispose();
      _activeSnapshot = null;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _handleAnimationTick() {
    if (widget.liveSampling && _controller.isAnimating) {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null && !boundary.debugNeedsPaint) {
        try {
          final pixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ??
              View.of(context).devicePixelRatio;
          final newImage = boundary.toImageSync(pixelRatio: pixelRatio);
          final oldImage = _activeSnapshot;
          _activeSnapshot = newImage;
          oldImage?.dispose();
        } catch (_) {
          // If frame is busy, smoothly keep previous frame
        }
      }
    }
  }

  /// Calculates the logical pixel offset corresponding to a [ShockwaveSide].
  Offset _offsetForSide(ShockwaveSide side, Size size) {
    final w = size.width;
    final h = size.height;

    switch (side) {
      case ShockwaveSide.top:
        return Offset(w * 0.5, 0.0);
      case ShockwaveSide.bottom:
        return Offset(w * 0.5, h);
      case ShockwaveSide.left:
        return Offset(0.0, h * 0.5);
      case ShockwaveSide.right:
        return Offset(w, h * 0.5);
      case ShockwaveSide.center:
        return Offset(w * 0.5, h * 0.5);
      case ShockwaveSide.topLeft:
        return Offset.zero;
      case ShockwaveSide.topRight:
        return Offset(w, 0.0);
      case ShockwaveSide.bottomLeft:
        return Offset(0.0, h);
      case ShockwaveSide.bottomRight:
        return Offset(w, h);
    }
  }

  /// Calculates the logical pixel offset corresponding to an [Alignment].
  Offset _offsetForAlignment(Alignment alignment, Size size) {
    return Offset(
      (alignment.x + 1.0) * 0.5 * size.width,
      (alignment.y + 1.0) * 0.5 * size.height,
    );
  }

  /// Triggers the liquid shockwave distortion effect.
  ///
  /// - [origin]: Center of the wave in logical coordinates relative to this container.
  ///   If null, the origin defaults to [widget.defaultSide] (e.g. top center).
  /// - [customDuration]: Optional duration override for this specific wave.
  Future<void> trigger([Offset? origin, Duration? customDuration]) async {
    if (!mounted || _program == null || _shader == null) {
      return;
    }

    final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      return;
    }

    // If repaint boundary needs paint, defer to next frame
    if (boundary.debugNeedsPaint) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) trigger(origin, customDuration);
      });
      return;
    }

    final pixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ??
        View.of(context).devicePixelRatio;

    final boundarySize = boundary.size;
    if (boundarySize.isEmpty) {
      return;
    }

    final effectiveOrigin = origin ?? _offsetForSide(widget.defaultSide, boundarySize);

    try {
      final ui.Image snapshot = await boundary.toImage(pixelRatio: pixelRatio);
      if (!mounted) {
        snapshot.dispose();
        return;
      }

      // Configure animation duration (custom override or widget default)
      _controller.duration = customDuration ?? widget.duration;

      // Reset controller value to 0 before swapping the snapshot.
      // Calling stop() and value = 0.0 avoids triggering dismissed status listeners.
      _controller.stop();
      _controller.value = 0.0;

      // Dispose any existing snapshot if interrupting an ongoing animation
      _activeSnapshot?.dispose();
      _activeSnapshot = snapshot;
      _currentOrigin = effectiveOrigin;

      _controller.forward();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('LiquidShockwaveContainer: snapshot capture error: $e');
    }
  }

  /// Triggers the shockwave from one of the screen/container sides (e.g. [ShockwaveSide.bottom],
  /// [ShockwaveSide.top], [ShockwaveSide.left], [ShockwaveSide.right]).
  /// Optionally accepts [customDuration] to override the animation speed.
  Future<void> triggerFromSide(ShockwaveSide side, [Duration? customDuration]) {
    final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    final size = boundary?.size ?? Size.zero;
    final origin = _offsetForSide(side, size);
    return trigger(origin, customDuration);
  }

  /// Triggers the shockwave from a fractional [Alignment] (e.g. [Alignment.bottomCenter]).
  /// Optionally accepts [customDuration] to override the animation speed.
  Future<void> triggerFromAlignment(Alignment alignment, [Duration? customDuration]) {
    final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    final size = boundary?.size ?? Size.zero;
    final origin = _offsetForAlignment(alignment, size);
    return trigger(origin, customDuration);
  }

  @override
  void dispose() {
    _controller.dispose();
    _cleanupSnapshot();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDistorting = _activeSnapshot != null && _controller.isAnimating;

    Widget childWidget = RepaintBoundary(
      key: _repaintBoundaryKey,
      child: widget.child,
    );

    if (widget.triggerOnTap) {
      childWidget = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) => trigger(details.localPosition),
        child: childWidget,
      );
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Hide child seamlessly while the snapshot shader is distorting
        // to prevent double-vision/ghosting, while preserving state & size.
        // If liveSampling is enabled, child must remain rendered to capture live frames.
        Visibility(
          visible: widget.liveSampling || !isDistorting,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: childWidget,
        ),
        if (isDistorting && _activeSnapshot != null && _shader != null)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  if (_activeSnapshot == null || _shader == null) {
                    return const SizedBox.shrink();
                  }
                  return CustomPaint(
                    painter: LiquidShockwavePainter(
                      shader: _shader!,
                      image: _activeSnapshot!,
                      progress: _animation.value,
                      origin: _currentOrigin,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// CustomPainter that maps coordinates, sets shader uniforms in exact order,
/// and renders the refractive shockwave distortion.
class LiquidShockwavePainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ui.Image image;
  final double progress;
  final Offset origin;

  LiquidShockwavePainter({
    required this.shader,
    required this.image,
    required this.progress,
    required this.origin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // In Flutter runtime_effect.glsl, FlutterFragCoord().xy corresponds to local canvas coordinates.
    // Setting uSize to canvas size ensures uv = FlutterFragCoord().xy / uSize ranges precisely [0.0, 1.0],
    // perfectly matching the captured snapshot without scaling or magnification artifacts.
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // Wave center origin in logical canvas coordinates
    shader.setFloat(2, origin.dx);
    shader.setFloat(3, origin.dy);

    // Animation progress 0.0 -> 1.0
    shader.setFloat(4, progress);

    // Snapshot texture
    shader.setImageSampler(0, image);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidShockwavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.origin != origin ||
        oldDelegate.image != image;
  }
}
