import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

/// Effect that plays when the user prestiges
/// 1. Implodes all elements to the center
/// 2. Flashes white
/// 3. Calls onComplete to reset the game
class PrestigeEffect extends Component with HasGameRef {
  final VoidCallback onComplete;
  final Component targetToImplode;

  PrestigeEffect({
    required this.onComplete,
    required this.targetToImplode,
  });

  @override
  Future<void> onLoad() async {
    // 1. Implode Animation
    // Scale down the target (OrbitSystem + Core) to near zero
    targetToImplode.add(
      ScaleEffect.to(
        Vector2.all(0.01),
        EffectController(
          duration: 1.5,
          curve: Curves.easeInExpo,
        ),
      ),
    );

    // Rotate it rapidly while shrinking
    targetToImplode.add(
      RotateEffect.by(
        pi * 4,
        EffectController(
          duration: 1.5,
          curve: Curves.easeInExpo,
        ),
      ),
    );

    // 2. White Flash Overlay
    // We'll add a white rectangle that fades in
    final whiteFlash = RectangleComponent(
      size: gameRef.size,
      paint: Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.0),
      priority: 1000, // Ensure it's on top
    );

    add(whiteFlash);

    // Fade in white flash at the end of the implode
    whiteFlash.add(
      OpacityEffect.to(
        1.0,
        EffectController(
          duration: 0.5,
          startDelay: 1.0, // Start fading in as implode finishes
          curve: Curves.easeOut,
          onMax: () {
            // 3. Trigger Reset
            onComplete();
            removeFromParent(); // Cleanup self
          },
        ),
      ),
    );
  }
}
