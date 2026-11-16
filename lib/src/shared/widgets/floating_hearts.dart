import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingHearts extends StatefulWidget {
  final double width;
  final double height;

  const FloatingHearts({
    super.key,
    this.width = 200,
    this.height = 120,
  });

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHeart({
    required double relativeX,
    required double relativeY,
    required double delay,
    required double size,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = (_controller.value + delay) % 1.0;

        // Float up by 45 pixels
        final double dy = -45.0 * progress;
        // Subtle horizontal sway
        final double dx = 4.0 * math.sin(progress * 2 * math.pi);

        // Opacity: fade in quickly, stay, then fade out
        double opacity = 0.0;
        if (progress < 0.2) {
          opacity = progress / 0.2;
        } else if (progress < 0.7) {
          opacity = 0.85;
        } else {
          opacity = (1.0 - progress) / 0.3 * 0.85;
        }

        // Scale up slightly as it rises
        final double scale = 0.6 + (0.5 * progress);

        return Positioned(
          left: relativeX * widget.width + dx,
          top: relativeY * widget.height + dy,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: Icon(
                Icons.favorite_rounded,
                size: size,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const heartColor = Color(0xFFE05370);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left heart
          _buildHeart(
            relativeX: 0.18,
            relativeY: 0.55,
            delay: 0.0,
            size: 18,
            color: heartColor,
          ),
          // Right heart
          _buildHeart(
            relativeX: 0.72,
            relativeY: 0.45,
            delay: 0.33,
            size: 20,
            color: heartColor,
          ),
          // Center-top heart
          _buildHeart(
            relativeX: 0.45,
            relativeY: 0.28,
            delay: 0.66,
            size: 22,
            color: heartColor,
          ),
        ],
      ),
    );
  }
}
