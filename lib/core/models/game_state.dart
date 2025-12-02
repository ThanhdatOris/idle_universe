import 'package:decimal/decimal.dart';
import 'package:idle_universe/core/utils/utils.dart';

import 'generator.dart';

/// GameState model - Trạng thái tổng thể của game
///
/// Quản lý:
/// - Năng lượng hiện tại và tổng thu nhập
/// - Danh sách generators
/// - Offline progress (last update time)
class GameState {
  /// Năng lượng hiện tại của người chơi
  Decimal energy;

  /// Tổng năng lượng đã kiếm được (lifetime)
  Decimal totalEnergyEarned;

  /// Thời điểm cập nhật cuối (để tính offline progress)
  DateTime lastUpdateTime;

  /// Danh sách tất cả generators
  List<Generator> generators;

  /// Global multiplier từ upgrades/prestige (1.0 = 100%)
  double globalMultiplier;

  /// Số lần click manual (cho achievements)
  int totalClicks;

  GameState({
    Decimal? energy,
    Decimal? totalEnergyEarned,
    DateTime? lastUpdateTime,
    List<Generator>? generators,
    this.globalMultiplier = 1.0,
    this.totalClicks = 0,
  })  : energy = energy ?? Decimal.zero,
        totalEnergyEarned = totalEnergyEarned ?? Decimal.zero,
        lastUpdateTime = lastUpdateTime ?? DateTime.now(),
        generators = generators ?? [];

  /// Tính tổng năng lượng/giây từ tất cả generators
  Decimal getEnergyPerSecond({Map<String, double>? generatorMultipliers}) {
    Decimal total = Decimal.zero;

    for (final generator in generators) {
      Decimal production = generator.getTotalProduction();

      // Apply generator-specific multiplier if available
      if (generatorMultipliers != null &&
          generatorMultipliers.containsKey(generator.id)) {
        final genMultiplier =
            Decimal.parse(generatorMultipliers[generator.id]!.toString());
        production = NumberFormatter.toDecimal(production * genMultiplier);
      }

      total = NumberFormatter.toDecimal(total + production);
    }

    // Áp dụng global multiplier
    final multiplierDecimal = Decimal.parse(globalMultiplier.toString());
    return NumberFormatter.toDecimal(total * multiplierDecimal);
  }

  /// Cập nhật năng lượng dựa trên thời gian đã trôi qua
  /// Trả về số năng lượng đã kiếm được
  Decimal updateEnergy({
    DateTime? currentTime,
    Map<String, double>? generatorMultipliers,
  }) {
    final now = currentTime ?? DateTime.now();
    final elapsedSeconds = now.difference(lastUpdateTime).inSeconds;

    if (elapsedSeconds <= 0) return Decimal.zero;

    final energyPerSec =
        getEnergyPerSecond(generatorMultipliers: generatorMultipliers);
    final earned = NumberFormatter.toDecimal(
        energyPerSec * Decimal.fromInt(elapsedSeconds));

    energy = NumberFormatter.toDecimal(energy + earned);
    totalEnergyEarned = NumberFormatter.toDecimal(totalEnergyEarned + earned);
    lastUpdateTime = now;

    return earned;
  }

  /// Thêm năng lượng thủ công (từ click button)
  void addEnergy(Decimal amount) {
    energy = NumberFormatter.toDecimal(energy + amount);
    totalEnergyEarned = NumberFormatter.toDecimal(totalEnergyEarned + amount);
    totalClicks++;
  }

  /// Trừ năng lượng (khi mua generator/upgrade)
  /// Trả về true nếu đủ tiền, false nếu không đủ
  bool spendEnergy(Decimal amount) {
    if (energy < amount) return false;

    energy = NumberFormatter.toDecimal(energy - amount);
    return true;
  }

  /// Kiểm tra có đủ năng lượng không
  bool canAfford(Decimal cost) {
    return energy >= cost;
  }

  /// Tìm generator theo ID
  Generator? getGenerator(String id) {
    try {
      return generators.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mua generator
  bool purchaseGenerator(String generatorId, {int amount = 1}) {
    final generator = getGenerator(generatorId);
    if (generator == null) return false;

    final cost = generator.getCurrentCost();
    if (!canAfford(cost)) return false;

    if (spendEnergy(cost)) {
      generator.purchase(amount: amount);
      return true;
    }

    return false;
  }

  /// Reset game (prestige)
  void reset({bool keepGenerators = false}) {
    energy = Decimal.zero;
    lastUpdateTime = DateTime.now();

    if (!keepGenerators) {
      for (final generator in generators) {
        generator.reset();
      }
    }
  }

  // === Serialization ===

  Map<String, dynamic> toJson() {
    return {
      'energy': energy.toString(),
      'totalEnergyEarned': totalEnergyEarned.toString(),
      'lastUpdateTime': lastUpdateTime.toIso8601String(),
      'generators': generators.map((g) => g.toJson()).toList(),
      'globalMultiplier': globalMultiplier,
      'totalClicks': totalClicks,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      energy: Decimal.parse(json['energy'] as String),
      totalEnergyEarned: Decimal.parse(json['totalEnergyEarned'] as String),
      lastUpdateTime: DateTime.parse(json['lastUpdateTime'] as String),
      generators: (json['generators'] as List)
          .map((g) => Generator.fromJson(g as Map<String, dynamic>))
          .toList(),
      globalMultiplier: (json['globalMultiplier'] as num?)?.toDouble() ?? 1.0,
      totalClicks: json['totalClicks'] as int? ?? 0,
    );
  }

  GameState copyWith({
    Decimal? energy,
    Decimal? totalEnergyEarned,
    DateTime? lastUpdateTime,
    List<Generator>? generators,
    double? globalMultiplier,
    int? totalClicks,
  }) {
    return GameState(
      energy: energy ?? this.energy,
      totalEnergyEarned: totalEnergyEarned ?? this.totalEnergyEarned,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      generators: generators ?? this.generators,
      globalMultiplier: globalMultiplier ?? this.globalMultiplier,
      totalClicks: totalClicks ?? this.totalClicks,
    );
  }

  @override
  String toString() {
    return 'GameState(energy: $energy, energyPerSec: ${getEnergyPerSecond()}, generators: ${generators.length})';
  }
}
