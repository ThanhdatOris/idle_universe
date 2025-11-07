import 'package:decimal/decimal.dart';

/// Upgrade model - Nâng cấp một lần (permanent boosts)
///
/// Các loại upgrade:
/// - Multiplier cho generator cụ thể
/// - Global multiplier
/// - Click power
/// - Unlock tính năng mới
class Upgrade {
  final String id;
  final String name;
  final String description;

  /// Giá của upgrade
  final Decimal cost;

  /// Loại upgrade
  final UpgradeType type;

  /// Giá trị effect (ví dụ: 2.0 = tăng gấp đôi)
  final double effectValue;

  /// Target của upgrade (generator ID hoặc 'global')
  final String? targetId;

  /// Icon cho UI
  final String icon;

  /// Đã mua chưa
  bool isPurchased;

  /// Yêu cầu (optional) - phải mua upgrade nào trước
  final String? requirementId;

  Upgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.type,
    required this.effectValue,
    this.targetId,
    this.icon = '⚡',
    this.isPurchased = false,
    this.requirementId,
  });

  /// Kiểm tra có thể mua không (dựa trên requirements)
  bool canPurchase(List<Upgrade> allUpgrades) {
    if (isPurchased) return false;

    // Kiểm tra requirement
    if (requirementId != null) {
      final requirement = allUpgrades.firstWhere(
        (u) => u.id == requirementId,
        orElse: () => this,
      );
      if (!requirement.isPurchased) return false;
    }

    return true;
  }

  /// Mua upgrade
  void purchase() {
    isPurchased = true;
  }

  /// Reset (cho prestige)
  void reset() {
    isPurchased = false;
  }

  // === Serialization ===

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost.toString(),
      'type': type.toString(),
      'effectValue': effectValue,
      'targetId': targetId,
      'icon': icon,
      'isPurchased': isPurchased,
      'requirementId': requirementId,
    };
  }

  factory Upgrade.fromJson(Map<String, dynamic> json) {
    return Upgrade(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      cost: Decimal.parse(json['cost'] as String),
      type: UpgradeType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      effectValue: (json['effectValue'] as num).toDouble(),
      targetId: json['targetId'] as String?,
      icon: json['icon'] as String? ?? '⚡',
      isPurchased: json['isPurchased'] as bool? ?? false,
      requirementId: json['requirementId'] as String?,
    );
  }

  Upgrade copyWith({
    String? id,
    String? name,
    String? description,
    Decimal? cost,
    UpgradeType? type,
    double? effectValue,
    String? targetId,
    String? icon,
    bool? isPurchased,
    String? requirementId,
  }) {
    return Upgrade(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      type: type ?? this.type,
      effectValue: effectValue ?? this.effectValue,
      targetId: targetId ?? this.targetId,
      icon: icon ?? this.icon,
      isPurchased: isPurchased ?? this.isPurchased,
      requirementId: requirementId ?? this.requirementId,
    );
  }

  @override
  String toString() {
    return 'Upgrade(id: $id, name: $name, purchased: $isPurchased)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Upgrade && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Loại upgrade
enum UpgradeType {
  /// Tăng production của generator cụ thể
  generatorMultiplier,

  /// Tăng toàn bộ production
  globalMultiplier,

  /// Tăng click power
  clickPower,

  /// Unlock generator mới
  unlockGenerator,

  /// Giảm cost của generator
  costReduction,

  /// Tính năng đặc biệt
  special,
}
