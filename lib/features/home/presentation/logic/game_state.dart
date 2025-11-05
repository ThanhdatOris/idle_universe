import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

@immutable
class GameState {
  final Decimal energy;
  final Decimal energyPerSecond;
  final Decimal energyUpgradeCost;
  final Decimal energyPerUpgrade; // Lượng E/s nhận được mỗi lần nâng

  final Decimal matter;
  final Decimal matterPerSecond;
  final Decimal matterProducerCost; // Chi phí (bằng Energy)
  final Decimal matterPerProducer;

  const GameState({
    required this.energy,
    required this.energyPerSecond,
    required this.energyUpgradeCost, // Thêm vào constructor
    required this.energyPerUpgrade, // Thêm vào constructor

    required this.matter,
    required this.matterPerSecond,
    required this.matterProducerCost,
    required this.matterPerProducer,
  });

  factory GameState.initial() {
    return GameState(
      energy: Decimal.zero,
      energyPerSecond: Decimal.one,
      energyUpgradeCost: Decimal.fromInt(10), // Chi phí ban đầu là 10
      energyPerUpgrade: Decimal.one, // Mỗi lần nâng cấp cộng 1

      matter: Decimal.zero,
      matterPerSecond: Decimal.zero, // Bắt đầu bằng 0
      matterProducerCost: Decimal.fromInt(100), // Chi phí 100 Energy
      matterPerProducer: Decimal.one, // Mỗi lần nâng cấp cộng 1 Matter/s
    );
  }

  GameState copyWith({
    Decimal? energy,
    Decimal? energyPerSecond,
    Decimal? energyUpgradeCost, // Thêm vào
    Decimal? energyPerUpgrade, // Thêm vào

    Decimal? matter,
    Decimal? matterPerSecond,
    Decimal? matterProducerCost,
    Decimal? matterPerProducer,
  }) {
    return GameState(
      energy: energy ?? this.energy,
      energyPerSecond: energyPerSecond ?? this.energyPerSecond,
      energyUpgradeCost: energyUpgradeCost ?? this.energyUpgradeCost,
      energyPerUpgrade: energyPerUpgrade ?? this.energyPerUpgrade,

      matter: matter ?? this.matter,
      matterPerSecond: matterPerSecond ?? this.matterPerSecond,
      matterProducerCost: matterProducerCost ?? this.matterProducerCost,
      matterPerProducer: matterPerProducer ?? this.matterPerProducer,
    );
  }
}