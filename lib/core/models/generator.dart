import 'package:decimal/decimal.dart';
import 'package:idle_universe/core/models/generator_milestone.dart';
import 'package:idle_universe/core/utils/utils.dart';

/// Generator model - Máy phát điện/Building trong idle game
///
/// Mỗi generator có:
/// - Base cost và cost multiplier (giá tăng theo số lượng mua)
/// - Base production (năng lượng/giây)
/// - Owned count (số lượng đã sở hữu)
/// - Milestones (bonus khi đạt số lượng nhất định)
class Generator {
  final String id;
  final String name;
  final String description;

  /// Giá gốc của generator đầu tiên
  final Decimal baseCost;

  /// Năng lượng/giây của 1 generator (chưa tính multipliers)
  final Decimal baseProduction;

  /// Hệ số tăng giá (mỗi lần mua giá = giá cũ * multiplier)
  /// Thường là 1.15 (tăng 15% mỗi lần mua)
  final double costMultiplier;

  /// Số lượng generator đã mua
  int owned;

  /// Icon/emoji cho UI
  final String icon;

  /// Milestones for this generator
  List<GeneratorMilestone> milestones;

  Generator({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.baseProduction,
    this.costMultiplier = 1.15,
    this.owned = 0,
    this.icon = '⚡',
    List<GeneratorMilestone>? milestones,
  }) : milestones = milestones ?? MilestoneConfig.getDefaultMilestones();

  /// Tính giá hiện tại dựa trên số lượng đã sở hữu
  /// Formula: baseCost * (costMultiplier ^ owned)
  Decimal getCurrentCost() {
    if (owned == 0) return baseCost;

    // Tính multiplier^owned
    double multiplier = 1.0;
    for (int i = 0; i < owned; i++) {
      multiplier *= costMultiplier;
    }

    // Chuyển sang Decimal và nhân với baseCost
    final multiplierDecimal = Decimal.parse(multiplier.toString());
    return NumberFormatter.toDecimal(baseCost * multiplierDecimal);
  }

  /// Tính tổng production của tất cả generators đã sở hữu
  /// (bao gồm milestone multipliers, chưa tính global multipliers)
  Decimal getTotalProduction() {
    if (owned == 0) return Decimal.zero;

    final ownedDecimal = Decimal.fromInt(owned);
    final baseTotal = baseProduction * ownedDecimal;

    // Apply milestone multipliers
    final milestoneMultiplier = getMilestoneMultiplier();
    final finalProduction =
        baseTotal * Decimal.parse(milestoneMultiplier.toString());

    return NumberFormatter.toDecimal(finalProduction);
  }

  /// Get total milestone multiplier
  double getMilestoneMultiplier() {
    double multiplier = 1.0;
    for (final milestone in milestones) {
      if (milestone.isUnlocked) {
        multiplier *= milestone.multiplier;
      }
    }
    return multiplier;
  }

  /// Check and unlock milestones based on current owned count
  /// Returns list of newly unlocked milestones
  List<GeneratorMilestone> checkMilestones() {
    final newlyUnlocked = <GeneratorMilestone>[];
    for (final milestone in milestones) {
      if (milestone.checkUnlock(owned)) {
        newlyUnlocked.add(milestone);
      }
    }
    return newlyUnlocked;
  }

  /// Get next milestone to unlock
  GeneratorMilestone? getNextMilestone() {
    for (final milestone in milestones) {
      if (!milestone.isUnlocked) {
        return milestone;
      }
    }
    return null; // All milestones unlocked
  }

  /// Mua thêm generator (tăng owned count)
  void purchase({int amount = 1}) {
    owned += amount;
    checkMilestones(); // Auto-check milestones after purchase
  }

  /// Tính tổng cost để mua thêm [amount] generator
  Decimal getCostForAmount(int amount) {
    if (amount <= 0) return Decimal.zero;

    Decimal totalCost = Decimal.zero;
    double multiplier = 1.0;

    // Calculate current multiplier base (multiplier^owned)
    for (int i = 0; i < owned; i++) {
      multiplier *= costMultiplier;
    }

    for (int i = 0; i < amount; i++) {
      final multiplierDecimal = Decimal.parse(multiplier.toString());
      // Use consistent formatting/rounding as getCurrentCost
      final itemCost = NumberFormatter.toDecimal(baseCost * multiplierDecimal);
      totalCost += itemCost;

      multiplier *= costMultiplier;
    }
    return totalCost;
  }

  /// Tính số lượng tối đa có thể mua với [energy]
  /// Trả về Map { 'amount': int, 'totalCost': Decimal }
  Map<String, dynamic> calculateMaxBuy(Decimal energy) {
    int count = 0;
    Decimal totalCost = Decimal.zero;
    double multiplier = 1.0;

    // Calculate current multiplier base
    for (int i = 0; i < owned; i++) {
      multiplier *= costMultiplier;
    }

    // Limit to 1000 to prevent infinite loops/performance issues
    while (count < 1000) {
      final multiplierDecimal = Decimal.parse(multiplier.toString());
      final itemCost = NumberFormatter.toDecimal(baseCost * multiplierDecimal);

      if (energy >= (totalCost + itemCost)) {
        totalCost += itemCost;
        count++;
        multiplier *= costMultiplier;
      } else {
        break;
      }
    }

    return {
      'amount': count,
      'totalCost': totalCost,
    };
  }

  /// Reset về 0 (dùng khi prestige)
  void reset() {
    owned = 0;
  }

  // === Serialization ===

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'baseCost': baseCost.toString(),
      'baseProduction': baseProduction.toString(),
      'costMultiplier': costMultiplier,
      'owned': owned,
      'icon': icon,
      'milestones': milestones.map((m) => m.toJson()).toList(),
    };
  }

  factory Generator.fromJson(Map<String, dynamic> json) {
    List<GeneratorMilestone>? milestones;
    if (json['milestones'] != null) {
      milestones = (json['milestones'] as List<dynamic>)
          .map((m) => GeneratorMilestone.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return Generator(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      baseCost: Decimal.parse(json['baseCost'] as String),
      baseProduction: Decimal.parse(json['baseProduction'] as String),
      costMultiplier: (json['costMultiplier'] as num).toDouble(),
      owned: json['owned'] as int,
      icon: json['icon'] as String? ?? '⚡',
      milestones: milestones,
    );
  }

  /// Copy with modified fields
  Generator copyWith({
    String? id,
    String? name,
    String? description,
    Decimal? baseCost,
    Decimal? baseProduction,
    double? costMultiplier,
    int? owned,
    String? icon,
  }) {
    return Generator(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      baseCost: baseCost ?? this.baseCost,
      baseProduction: baseProduction ?? this.baseProduction,
      costMultiplier: costMultiplier ?? this.costMultiplier,
      owned: owned ?? this.owned,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'Generator(id: $id, name: $name, owned: $owned, cost: ${getCurrentCost()}, production: ${getTotalProduction()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Generator && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
