import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'core_star_component.dart';
import 'orbit_system_component.dart';
import 'prestige_effect.dart';
import 'resource_particle.dart';

/// UniverseGame - Flame game instance for background visuals
class UniverseGame extends FlameGame {
  final Random _random = Random();

  final VoidCallback? onCoreTap;
  late CoreStarComponent _coreStar;
  late OrbitSystemComponent _orbitSystem;

  // Container for game elements that will be imploded
  late PositionComponent _gameWorld;

  Map<String, int>? _pendingGeneratorCounts;
  bool _isLoaded = false;

  UniverseGame({this.onCoreTap});

  @override
  Color backgroundColor() => const Color(0xFF050510); // Deep cosmic blue/black

  late Sprite _particleSprite;
  late Sprite _starSprite;

  @override
  Future<void> onLoad() async {
    // Load 8-bit assets
    await images.loadAll([
      'sun_8bit.png',
      'planets_8bit.png',
      'particles_8bit.png',
    ]);

    // Create sprites from sheet
    final particleSheet = images.fromCache('particles_8bit.png');
    final spriteSize = particleSheet.width / 3;

    _starSprite = Sprite(
      particleSheet,
      srcPosition: Vector2(0, 0),
      srcSize: Vector2(spriteSize, particleSheet.height.toDouble()),
    );

    _particleSprite = Sprite(
      particleSheet,
      srcPosition: Vector2(spriteSize * 2, 0), // 3rd item
      srcSize: Vector2(spriteSize, particleSheet.height.toDouble()),
    );

    final center = Vector2(size.x / 2, size.y / 2);

    // Create a world container for easier manipulation (like prestige implode)
    _gameWorld = PositionComponent(
      position: Vector2.zero(),
      size: size,
    );
    add(_gameWorld);

    // Add stars to world
    for (int i = 0; i < 100; i++) {
      _gameWorld.add(StarComponent(
        position: Vector2(
          _random.nextDouble() * size.x,
          _random.nextDouble() * size.y,
        ),
        size: _random.nextDouble() * 2 + 1,
        sprite: _starSprite,
      ));
    }

    // Add Orbit System (Planets) to world
    _orbitSystem = OrbitSystemComponent(
      position: center,
      planetSpriteSheet: images.fromCache('planets_8bit.png'),
    );
    _gameWorld.add(_orbitSystem);

    // Add Core Star (Interactive Tap Area) to world
    _coreStar = CoreStarComponent(
      position: center,
      size: 120, // Size of the star
      sprite: Sprite(images.fromCache('sun_8bit.png')),
      onTap: () {
        onCoreTap?.call();
        spawnClickEffect(_coreStar.position);
      },
    );
    _gameWorld.add(_coreStar);

    _isLoaded = true;

    // Apply pending updates
    if (_pendingGeneratorCounts != null) {
      _orbitSystem.updateGenerators(_pendingGeneratorCounts!);
      _pendingGeneratorCounts = null;
    }
  }

  /// Update generator visuals
  void updateGenerators(Map<String, int> generatorCounts) {
    if (_isLoaded) {
      _orbitSystem.updateGenerators(generatorCounts);
    } else {
      _pendingGeneratorCounts = generatorCounts;
    }
  }

  /// Trigger Prestige Animation
  void triggerPrestige(VoidCallback onComplete) {
    if (!_isLoaded) {
      onComplete();
      return;
    }

    add(PrestigeEffect(
      targetToImplode: _gameWorld,
      onComplete: () {
        // Reset world state visually
        _gameWorld.scale = Vector2.all(1.0);
        _gameWorld.angle = 0;

        // Callback to reset game logic
        onComplete();
      },
    ));
  }

  /// Spawn resource collection effect
  void spawnResourceCollection() {
    if (!_isLoaded) return;

    if (_orbitSystem.children.isEmpty) return;

    // Spawn 1-3 particles per tick if there are generators
    final count = 1 + _random.nextInt(3);

    for (int i = 0; i < count; i++) {
      // Pick a random angle and radius to simulate a planet position
      final angle = _random.nextDouble() * 2 * pi;
      final radius = 100.0 + _random.nextDouble() * 150.0;

      final startPos = Vector2(
        size.x / 2 + cos(angle) * radius,
        size.y / 2 + sin(angle) * radius,
      );

      // Target is top center (Resource Bar)
      final targetPos = Vector2(size.x / 2, 40.0);

      // Add to game root, not world, so it's not affected by world transforms if any
      add(ResourceParticle(
        startPosition: startPos,
        targetPosition: targetPos,
        sprite: _particleSprite,
      ));
    }
  }

  void spawnClickEffect(Vector2 position) {
    for (int i = 0; i < 8; i++) {
      // Add to world so it moves with it
      _gameWorld.add(EnergyParticle(
        position: position,
        sprite: _particleSprite,
      ));
    }
  }
}

/// StarComponent - Simple twinkling star
class StarComponent extends SpriteComponent {
  late double _twinkleSpeed;
  late double _baseAlpha;
  double _time = 0;

  StarComponent({
    required Vector2 position,
    required double size,
    required Sprite sprite,
  }) : super(
          position: position,
          size: Vector2.all(size),
          sprite: sprite,
          anchor: Anchor.center,
        ) {
    _twinkleSpeed = 0.5 + Random().nextDouble() * 2.0;
    _baseAlpha = 0.3 + Random().nextDouble() * 0.5;

    // Set initial alpha
    setColor(Colors.white.withValues(alpha: _baseAlpha));
  }

  @override
  void update(double dt) {
    _time += dt * _twinkleSpeed;
    // Simple sine wave twinkle
    final alphaChange = sin(_time) * 0.2;
    final newAlpha = (_baseAlpha + alphaChange).clamp(0.1, 1.0);

    setColor(Colors.white.withValues(alpha: newAlpha));
  }
}

/// EnergyParticle - Particle emitted on click
class EnergyParticle extends SpriteComponent {
  final Vector2 velocity;
  double lifeTime = 1.0;
  final double maxLifeTime = 1.0;

  EnergyParticle({
    required Vector2 position,
    required Sprite sprite,
  })  : velocity = Vector2(
          (Random().nextDouble() - 0.5) * 200,
          (Random().nextDouble() - 0.5) * 200,
        ),
        super(
          position: position,
          size: Vector2.all(8),
          sprite: sprite,
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    position += velocity * dt;
    lifeTime -= dt;
    if (lifeTime <= 0) {
      removeFromParent();
    }

    // Fade out
    final alpha = (lifeTime / maxLifeTime).clamp(0.0, 1.0);
    setColor(Colors.white.withValues(alpha: alpha));
  }
}
