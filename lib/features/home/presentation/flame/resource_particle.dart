import 'package:flame/components.dart';

/// ResourceParticle - Visual representation of collected resources
///
/// Behavior:
/// - Spawns at a generator (planet) position
/// - Flies towards the resource bar (top of screen)
/// - Fades out as it reaches the destination
class ResourceParticle extends SpriteComponent {
  final Vector2 targetPosition;
  final double speed;

  // Movement state
  late Vector2 _velocity;
  double _lifeTime = 0;
  final double _maxLifeTime = 1.5; // Seconds to reach top

  ResourceParticle({
    required Vector2 startPosition,
    required this.targetPosition,
    required Sprite sprite,
    this.speed = 400.0,
  }) : super(
          position: startPosition,
          size: Vector2.all(12), // Slightly larger for pixel art visibility
          anchor: Anchor.center,
          sprite: sprite,
        );

  @override
  Future<void> onLoad() async {
    // Calculate velocity towards target
    final direction = (targetPosition - position).normalized();
    _velocity = direction * speed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime += dt;

    // Move towards target
    position += _velocity * dt;

    // Check if reached target (top of screen area)
    if (position.y <= targetPosition.y || _lifeTime >= _maxLifeTime) {
      removeFromParent();
    }
  }
}
