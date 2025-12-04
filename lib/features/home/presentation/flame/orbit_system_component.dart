import 'dart:math';
import 'dart:ui' as ui; // Import ui for Image type

import 'package:flame/components.dart';

/// OrbitSystemComponent - Manages planets orbiting the core star
class OrbitSystemComponent extends PositionComponent {
  final List<PlanetComponent> _planets = [];
  final ui.Image planetSpriteSheet;

  OrbitSystemComponent({
    required Vector2 position,
    required this.planetSpriteSheet,
  }) : super(position: position);

  /// Update the visual representation based on owned generators
  void updateGenerators(Map<String, int> generatorCounts) {
    // Clear existing planets (naive approach, can be optimized)
    for (final planet in _planets) {
      planet.removeFromParent();
    }
    _planets.clear();

    // Calculate sprite dimensions (assuming 6 planets in a row)
    final double spriteWidth = planetSpriteSheet.width / 6;
    final double spriteHeight = planetSpriteSheet.height.toDouble();

    // Add planets based on counts
    // We limit the number of visual planets to avoid clutter
    int orbitIndex = 1;
    int generatorIndex = 0; // To track which sprite to use

    generatorCounts.forEach((id, count) {
      if (count > 0) {
        // Create sprite for this generator type
        // Clamp index to 5 (last planet) just in case
        final spriteIndex = min(generatorIndex, 5);
        final sprite = Sprite(
          planetSpriteSheet,
          srcPosition: Vector2(spriteIndex * spriteWidth, 0),
          srcSize: Vector2(spriteWidth, spriteHeight),
        );

        final radius =
            8.0 + (orbitIndex * 1.0); // Planets get slightly larger further out
        final orbitRadius = 80.0 + (orbitIndex * 25.0);
        final speed = 1.0 / orbitIndex; // Outer planets move slower

        // Show up to 5 planets per type to represent quantity
        final visualCount = min(count, 5);

        for (int i = 0; i < visualCount; i++) {
          final startAngle = (i * (2 * pi / visualCount)) + (orbitIndex * 0.5);

          final planet = PlanetComponent(
            orbitRadius: orbitRadius,
            radius: radius,
            sprite: sprite,
            speed: speed,
            startAngle: startAngle,
          );

          add(planet);
          _planets.add(planet);
        }

        orbitIndex++;
      }
      generatorIndex++;
    });
  }
}

class PlanetComponent extends SpriteComponent {
  final double orbitRadius;
  final double speed;
  double _angle;

  PlanetComponent({
    required this.orbitRadius,
    required double radius,
    required Sprite sprite,
    required this.speed,
    required double startAngle,
  })  : _angle = startAngle,
        super(
          anchor: Anchor.center,
          size: Vector2.all(radius * 2), // Size is diameter
          sprite: sprite,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _angle += speed * dt;

    // Update position based on orbit
    position = Vector2(
      cos(_angle) * orbitRadius,
      sin(_angle) * orbitRadius,
    );
  }
}
