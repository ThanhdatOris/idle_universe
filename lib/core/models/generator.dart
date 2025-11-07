import 'package:decimal/decimal.dart';
import 'package:idle_universe/core/utils/utils.dart';

/// Generator model - Máy phát điện/Building trong idle game
///
/// Mỗi generator có:
/// - Base cost và cost multiplier (giá tăng theo số lượng mua)
/// - Base production (năng lượng/giây)
/// - Owned count (số lượng đã sở hữu)
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

  Generator({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.baseProduction,
    this.costMultiplier = 1.15,
    this.owned = 0,
    this.icon = '⚡',
  });

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
  /// (chưa tính global multipliers từ upgrades/prestige)
  Decimal getTotalProduction() {
    if (owned == 0) return Decimal.zero;

    final ownedDecimal = Decimal.fromInt(owned);
    return NumberFormatter.toDecimal(baseProduction * ownedDecimal);
  }

  /// Mua thêm generator (tăng owned count)
  void purchase({int amount = 1}) {
    owned += amount;
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
    };
  }

  factory Generator.fromJson(Map<String, dynamic> json) {
    return Generator(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      baseCost: Decimal.parse(json['baseCost'] as String),
      baseProduction: Decimal.parse(json['baseProduction'] as String),
      costMultiplier: (json['costMultiplier'] as num).toDouble(),
      owned: json['owned'] as int,
      icon: json['icon'] as String? ?? '⚡',
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
