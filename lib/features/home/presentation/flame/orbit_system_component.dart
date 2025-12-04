import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// OrbitSystemComponent - Manages planets orbiting the core star
class OrbitSystemComponent extends PositionComponent {
  final List<PlanetComponent> _planets = [];

  OrbitSystemComponent({required Vector2 position}) : super(position: position);

  /// Update the visual representation based on owned generators
  void updateGenerators(Map<String, int> generatorCounts) {
    // Clear existing planets (naive approach, can be optimized)
    for (final planet in _planets) {
      planet.removeFromParent();
    }
    _planets.clear();

    // Add planets based on counts
    // We limit the number of visual planets to avoid clutter
    int orbitIndex = 1;

    generatorCounts.forEach((id, count) {
      if (count > 0) {
        // Determine planet type/color based on ID
        final color = _getPlanetColor(id);
        final radius =
            5.0 + (orbitIndex * 0.5); // Planets get slightly larger further out
        final orbitRadius = 80.0 + (orbitIndex * 25.0);
        final speed = 1.0 / orbitIndex; // Outer planets move slower

        // Show up to 5 planets per type to represent quantity
        final visualCount = min(count, 5);

        for (int i = 0; i < visualCount; i++) {
          final startAngle = (i * (2 * pi / visualCount)) + (orbitIndex * 0.5);

          final planet = PlanetComponent(
            orbitRadius: orbitRadius,
            radius: radius,
            color: color,
            speed: speed,
            startAngle: startAngle,
          );

          add(planet);
          _planets.add(planet);
        }

        orbitIndex++;
      }
    });
  }

  Color _getPlanetColor(String id) {
    // Map generator IDs to colors
    // This should ideally come from the Generator model or config
    switch (id) {
      case 'gen_001':
        return Colors.cyanAccent; // Photon
      case 'gen_002':
        return Colors.greenAccent; // Electron
      case 'gen_003':
        return Colors.yellowAccent; // Solar
      case 'gen_004':
        return Colors.orangeAccent; // Fusion
      case 'gen_005':
        return Colors.purpleAccent; // Neutron
      case 'gen_006':
        return Colors.redAccent; // Big Bang
      default:
        return Colors.white;
    }
  }
}

class PlanetComponent extends PositionComponent {
  final double orbitRadius;
  final double radius;
  final Color color;
  final double speed;
  double _angle;

  PlanetComponent({
    required this.orbitRadius,
    required this.radius,
    required this.color,
    required this.speed,
    required double startAngle,
  })  : _angle = startAngle,
        super(anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Draw orbit trail (faint)
    // Note: Drawing full orbit circles for every planet might be expensive
    // We can optimize this by drawing orbits in the parent component

    // Draw planet
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset.zero, radius, paint);

    // Draw simple glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawCircle(Offset.zero, radius + 2, glowPaint);
  }

  @override
  void update(double dt) {
    _angle += speed * dt;

    // Update position based on orbit
    position = Vector2(
      cos(_angle) * orbitRadius,
      sin(_angle) * orbitRadius,
    );
  }
}
