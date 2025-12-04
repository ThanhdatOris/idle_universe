import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// UniverseGame - Flame game instance for background visuals
class UniverseGame extends FlameGame {
  final Random _random = Random();

  @override
  Color backgroundColor() => const Color(0xFF050510); // Deep cosmic blue/black

  @override
  Future<void> onLoad() async {
    // Add stars
    for (int i = 0; i < 100; i++) {
      add(StarComponent(
        position: Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * size.y,
        ),
        size: _random.nextDouble() * 2 + 1,
      ));
    }
  }

  /// Spawn a particle explosion at position
  void spawnClickEffect(Vector2 position) {
    for (int i = 0; i < 8; i++) {
      add(EnergyParticle(position: position));
    }
  }
}

/// StarComponent - Simple twinkling star
class StarComponent extends PositionComponent {
  late double _twinkleSpeed;
  late double _baseAlpha;
  double _time = 0;

  StarComponent({required Vector2 position, required double size})
      : super(position: position, size: Vector2.all(size)) {
    _twinkleSpeed = 0.5 + Random().nextDouble() * 2.0;
    _baseAlpha = 0.3 + Random().nextDouble() * 0.5;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: _baseAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }

  @override
  void update(double dt) {
    _time += dt * _twinkleSpeed;
    // Simple sine wave twinkle
    final alphaChange = sin(_time) * 0.2;
    final newAlpha = (_baseAlpha + alphaChange).clamp(0.1, 1.0);
    _baseAlpha = newAlpha;
  }
}

/// EnergyParticle - Particle emitted on click
class EnergyParticle extends PositionComponent {
  final Vector2 velocity;
  double lifeTime = 1.0;
  final double maxLifeTime = 1.0;

  EnergyParticle({required Vector2 position})
      : velocity = Vector2(
          (Random().nextDouble() - 0.5) * 200,
          (Random().nextDouble() - 0.5) * 200,
        ),
        super(position: position, size: Vector2.all(4));

  @override
  void update(double dt) {
    position += velocity * dt;
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final alpha = (lifeTime / maxLifeTime).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = Colors.amber.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }
}
