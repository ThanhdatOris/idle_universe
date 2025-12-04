import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// CoreStarComponent - The central interactive star
///
/// Behavior:
/// - Pulses gently when idle
/// - Squashes and stretches on tap
/// - Emits particles on tap
class CoreStarComponent extends SpriteComponent with TapCallbacks {
  final VoidCallback onTap;

  // Animation state
  double _time = 0;
  double _pulseSpeed = 2.0;
  double _baseScale = 1.0;
  double _currentScale = 1.0;

  // Tap effect state
  bool _isPressed = false;
  double _squashFactor = 0.9;

  CoreStarComponent({
    required Vector2 position,
    required double size,
    required Sprite sprite,
    required this.onTap,
  }) : super(
          position: position,
          size: Vector2.all(size),
          anchor: Anchor.center,
          sprite: sprite,
        );

  @override
  void render(Canvas canvas) {
    // Draw glow behind the sun
    final radius = size.x / 2;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.amber.withValues(alpha: 0.4),
          Colors.orange.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(radius, radius), radius: radius * 1.5));

    canvas.drawCircle(Offset(radius, radius), radius * 1.5, glowPaint);

    // Draw the sprite (sun)
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt * _pulseSpeed;

    // Idle pulse animation
    final pulse = sin(_time) * 0.05 + 1.0;

    // Combine with tap squash effect
    double targetScale = _isPressed ? _squashFactor : _baseScale * pulse;

    // Smooth interpolation
    _currentScale += (targetScale - _currentScale) * dt * 10;

    scale = Vector2.all(_currentScale);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    onTap(); // Trigger game logic
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}
