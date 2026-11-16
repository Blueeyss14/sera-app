import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../res/assets.dart';
import '../../../res/colors.dart';

class MascotFloat extends StatefulWidget {
  final Widget child;
  final double distance;
  final Duration duration;

  const MascotFloat({
    super.key,
    required this.child,
    this.distance = 5.0,
    this.duration = const Duration(milliseconds: 3600),
  });

  @override
  State<MascotFloat> createState() => _MascotFloatState();
}

class _MascotFloatState extends State<MascotFloat> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: -widget.distance).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class MascotSway extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const MascotSway({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<MascotSway> createState() => _MascotSwayState();
}

class _MascotSwayState extends State<MascotSway> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angleAnimation;
  late final Animation<double> _yAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _angleAnimation = Tween<double>(begin: -0.1047, end: 0.1047).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _yAnimation = Tween<double>(begin: 0, end: -2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _yAnimation.value),
        child: Transform.rotate(
          angle: _angleAnimation.value,
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class PeekingMascot extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PeekingMascot({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 7000),
  });

  @override
  State<PeekingMascot> createState() => _PeekingMascotState();
}

class _PeekingMascotState extends State<PeekingMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _peekAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    _peekAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.05),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 0.12)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.12),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.12, end: 0.32)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.32),
        weight: 38,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.32, end: 0.40)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.40, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.05),
        weight: 12,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _peekAnimation,
      builder: (context, child) => FractionalTranslation(
        translation: Offset(0, _peekAnimation.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class InteractiveMascot extends StatefulWidget {
  final double size;

  const InteractiveMascot({super.key, this.size = 56});

  @override
  State<InteractiveMascot> createState() => _InteractiveMascotState();
}

class _InteractiveMascotState extends State<InteractiveMascot> with TickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final Animation<double> _jumpAnimation;
  late final AnimationController _heartController;
  late final Animation<double> _heartOpacityAnimation;
  late final Animation<double> _heartYAnimation;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -14).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -14, end: 0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_jumpController);

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _heartOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 80,
      ),
    ]).animate(_heartController);

    _heartYAnimation = Tween<double>(begin: 0, end: -36).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOut),
    );
  }

  void _onTap() {
    _jumpController.forward(from: 0);
    _heartController.forward(from: 0);
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _heartController,
              builder: (context, child) {
                if (_heartController.value == 0 || _heartController.isCompleted) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  top: _heartYAnimation.value - 6,
                  left: -6,
                  right: -6,
                  child: Opacity(
                    opacity: _heartOpacityAnimation.value,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(LucideIcons.heart, color: Color(0xFFEF4444), size: 14),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Icon(LucideIcons.heart, color: Color(0xFFF43F5E), size: 18),
                        ),
                        Icon(LucideIcons.heart, color: Color(0xFFEF4444), size: 13),
                      ],
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _jumpController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _jumpAnimation.value),
                child: child,
              ),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorValues.primary,
                ),
                child: ClipOval(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: MascotSway(
                        child: Image.asset(
                          ImageAssets.seraHappy,
                          width: widget.size * 0.88,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JumpingMascot extends StatefulWidget {
  final String imageAsset;
  final double width;

  const JumpingMascot({
    super.key,
    required this.imageAsset,
    this.width = 68,
  });

  @override
  State<JumpingMascot> createState() => _JumpingMascotState();
}

class _JumpingMascotState extends State<JumpingMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -14).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -14, end: 0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
      ),
    ]).animate(_jumpController);
  }

  void _onTap() {
    _jumpController.forward(from: 0);
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _jumpController,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _jumpAnimation.value),
          child: child,
        ),
        child: MascotFloat(
          child: Image.asset(
            widget.imageAsset,
            width: widget.width,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
