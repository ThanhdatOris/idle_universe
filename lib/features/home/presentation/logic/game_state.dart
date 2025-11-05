import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

@immutable
class GameState {
  final Decimal energy;
  final Decimal energyPerSecond;
  
  final Decimal energyUpgradeCost;
  final Decimal energyPerUpgrade; // Lượng E/s nhận được mỗi lần nâng

  const GameState({
    required this.energy,
    required this.energyPerSecond,
    required this.energyUpgradeCost, // Thêm vào constructor
    required this.energyPerUpgrade, // Thêm vào constructor
  });

  factory GameState.initial() {
    return GameState(
      energy: Decimal.zero,
      energyPerSecond: Decimal.one,
      energyUpgradeCost: Decimal.fromInt(10), // Chi phí ban đầu là 10
      energyPerUpgrade: Decimal.one, // Mỗi lần nâng cấp cộng 1
    );
  }

  GameState copyWith({
    Decimal? energy,
    Decimal? energyPerSecond,
    Decimal? energyUpgradeCost, // Thêm vào
    Decimal? energyPerUpgrade, // Thêm vào
  }) {
    return GameState(
      energy: energy ?? this.energy,
      energyPerSecond: energyPerSecond ?? this.energyPerSecond,
      energyUpgradeCost: energyUpgradeCost ?? this.energyUpgradeCost,
      energyPerUpgrade: energyPerUpgrade ?? this.energyPerUpgrade,
    );
  }
}