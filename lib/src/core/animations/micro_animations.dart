import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'animation_constants.dart';

/// Shake animation widget for error states
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool shake;
  final VoidCallback? onShakeComplete;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.shake = false,
    this.onShakeComplete,
  });

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        widget.onShakeComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sineValue = math.sin(_animation.value * math.pi * 4);
        return Transform.translate(
          offset: Offset(sineValue * 10, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Scale pulse animation for selection feedback
class ScalePulseAnimation extends StatefulWidget {
  final Widget child;
  final bool pulse;
  final double scale;

  const ScalePulseAnimation({
    super.key,
    required this.child,
    this.pulse = false,
    this.scale = AnimationConstants.scalePulse,
  });

  @override
  State<ScalePulseAnimation> createState() => _ScalePulseAnimationState();
}

class _ScalePulseAnimationState extends State<ScalePulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.durationMedium,
      vsync: this,
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.scale)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.scale, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(ScalePulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !oldWidget.pulse) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// Animated success checkmark
class AnimatedCheckmark extends StatefulWidget {
  final double size;
  final Color color;
  final bool show;
  final Duration duration;

  const AnimatedCheckmark({
    super.key,
    this.size = 64,
    this.color = Colors.white,
    this.show = true,
    this.duration = AnimationConstants.durationLong,
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    if (widget.show) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CheckmarkPainter(
            progress: _animation.value,
            color: widget.color,
            strokeWidth: widget.size * 0.1,
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Checkmark path points (relative to size)
    final start = Offset(size.width * 0.2, size.height * 0.5);
    final middle = Offset(size.width * 0.4, size.height * 0.7);
    final end = Offset(size.width * 0.8, size.height * 0.3);

    // Calculate how much of the path to draw
    final totalLength = (middle - start).distance + (end - middle).distance;
    final drawnLength = totalLength * progress;

    path.moveTo(start.dx, start.dy);

    final firstSegmentLength = (middle - start).distance;
    
    if (drawnLength <= firstSegmentLength) {
      // Draw partial first segment
      final t = drawnLength / firstSegmentLength;
      final point = Offset.lerp(start, middle, t)!;
      path.lineTo(point.dx, point.dy);
    } else {
      // Draw full first segment and partial second
      path.lineTo(middle.dx, middle.dy);
      final remainingLength = drawnLength - firstSegmentLength;
      final secondSegmentLength = (end - middle).distance;
      final t = remainingLength / secondSegmentLength;
      final point = Offset.lerp(middle, end, t.clamp(0, 1))!;
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Fade and slide animation for entering content
class FadeSlideAnimation extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final Offset beginOffset;

  const FadeSlideAnimation({
    super.key,
    required this.child,
    required this.animation,
    this.beginOffset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AnimationConstants.curveEmphasized,
        )),
        child: child,
      ),
    );
  }
}

/// Staggered animation controller helper
class StaggeredAnimationController {
  final int itemCount;
  final Duration itemDuration;
  final Duration staggerDelay;

  StaggeredAnimationController({
    required this.itemCount,
    this.itemDuration = AnimationConstants.durationMedium,
    this.staggerDelay = AnimationConstants.staggerDelay,
  });

  /// Get the interval for a specific item
  Interval getInterval(int index) {
    final totalDuration = itemDuration + (staggerDelay * (itemCount - 1));
    final startTime = staggerDelay.inMilliseconds * index;
    final endTime = startTime + itemDuration.inMilliseconds;
    
    return Interval(
      startTime / totalDuration.inMilliseconds,
      endTime / totalDuration.inMilliseconds,
      curve: AnimationConstants.curveEmphasized,
    );
  }

  /// Total duration needed for all items
  Duration get totalDuration =>
      itemDuration + (staggerDelay * (itemCount - 1));
}
