import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ResourceParticle - Visual representation of collected resources
///
/// Behavior:
/// - Spawns at a generator (planet) position
/// - Flies towards the resource bar (top of screen)
/// - Fades out as it reaches the destination
class ResourceParticle extends PositionComponent {
  final Vector2 targetPosition;
  final double speed;
  final Color color;

  // Movement state
  late Vector2 _velocity;
  double _lifeTime = 0;
  final double _maxLifeTime = 1.5; // Seconds to reach top

  ResourceParticle({
    required Vector2 startPosition,
    required this.targetPosition,
    this.color = Colors.amber,
    this.speed = 400.0,
  }) : super(
            position: startPosition,
            size: Vector2.all(6),
            anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Calculate velocity towards target
    final direction = (targetPosition - position).normalized();
    _velocity = direction * speed;
  }

  @override
  void update(double dt) {
    _lifeTime += dt;

    // Move towards target
    position += _velocity * dt;

    // Check if reached target (top of screen area)
    if (position.y <= targetPosition.y || _lifeTime >= _maxLifeTime) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a small glowing orb
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

    // Trail effect (simple)
    final trailPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final trailEnd = Offset(
        size.x / 2 - _velocity.x * 0.02, size.y / 2 - _velocity.y * 0.02);

    canvas.drawLine(Offset(size.x / 2, size.y / 2), trailEnd, trailPaint);
  }
}
