import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedTextSheen extends StatefulWidget {
  const AnimatedTextSheen({
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1600),
    super.key,
  });

  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  @override
  State<AnimatedTextSheen> createState() => _AnimatedTextSheenState();
}

class _AnimatedTextSheenState extends State<AnimatedTextSheen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTextSheen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration && _controller != null) {
      _controller!.duration = widget.duration;
    }

    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _startAnimation() {
    final controller = _controller ??= AnimationController(vsync: this, duration: widget.duration);
    controller.repeat();
  }

  void _stopAnimation() {
    _controller?.stop();
    if (_controller != null) {
      _controller!.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (!widget.enabled || controller == null) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75);
    final highlightColor = widget.highlightColor ?? Color.lerp(baseColor, Colors.white, 0.4)!;

    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            final travel = bounds.width + 120;
            final offsetX = lerpDouble(bounds.width, -120, controller.value) ?? 0;

            return LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [baseColor, baseColor, highlightColor, baseColor, baseColor],
              stops: const [0, 0.34, 0.5, 0.66, 1],
              transform: _SlidingGradientTransform(offsetX / travel),
            ).createShader(Rect.fromLTWH(0, 0, bounds.width + 120, bounds.height));
          },
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slideFactor);

  final double slideFactor;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slideFactor, 0, 0);
  }
}