import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:idle_universe/core/utils/utils.dart';

/// PrestigeData model - Dữ liệu về Prestige/Reset
///
/// Prestige cho phép:
/// - Reset game để nhận prestige points
/// - Prestige points tăng production multiplier vĩnh viễn
/// - Unlock các upgrade mạnh hơn
class PrestigeData {
  /// Số lần đã prestige
  int prestigeCount;

  /// Tổng prestige points hiện có
  Decimal prestigePoints;

  /// Prestige points đã tiêu (để tính total lifetime)
  Decimal prestigePointsSpent;

  /// Multiplier từ prestige (tính từ prestigePoints)
  /// Formula thường dùng: 1 + (prestigePoints * 0.01) = +1% per point
  double get prestigeMultiplier {
    final points = prestigePoints.toDouble();
    return 1.0 + (points * 0.01); // +1% mỗi prestige point
  }

  /// Thời gian prestige lần cuối
  DateTime? lastPrestigeTime;

  /// Lifetime prestige points (bao gồm cả đã tiêu)
  Decimal get totalPrestigePointsEarned {
    return NumberFormatter.toDecimal(prestigePoints + prestigePointsSpent);
  }

  PrestigeData({
    this.prestigeCount = 0,
    Decimal? prestigePoints,
    Decimal? prestigePointsSpent,
    this.lastPrestigeTime,
  })  : prestigePoints = prestigePoints ?? Decimal.zero,
        prestigePointsSpent = prestigePointsSpent ?? Decimal.zero;

  /// Tính số prestige points sẽ nhận được nếu prestige bây giờ
  /// Formula: sqrt(totalEnergyEarned / 1e15) - già có
  ///
  /// Ví dụ:
  /// - 1e15 energy → 1 point
  /// - 1e16 energy → 3.16 points
  /// - 1e18 energy → 31.6 points
  static Decimal calculatePrestigeGain(
      Decimal totalEnergyEarned, Decimal currentPrestigePoints) {
    final threshold = Decimal.parse('1000000000000000'); // 1e15

    if (totalEnergyEarned < threshold) return Decimal.zero;

    // sqrt(totalEnergy / 1e15)
    final ratio = totalEnergyEarned / threshold;
    final ratioDouble = ratio.toDouble();
    final sqrtValue = math.sqrt(ratioDouble);
    final potentialPoints = Decimal.parse(sqrtValue.toString());

    // Trừ đi số points đã có (để không bị lặp lại)
    final gain =
        NumberFormatter.toDecimal(potentialPoints - currentPrestigePoints);

    return gain > Decimal.zero ? gain : Decimal.zero;
  }

  /// Kiểm tra có thể prestige không
  static bool canPrestige(
      Decimal totalEnergyEarned, Decimal currentPrestigePoints) {
    final gain =
        calculatePrestigeGain(totalEnergyEarned, currentPrestigePoints);
    return gain > Decimal.zero;
  }

  /// Thực hiện prestige (nhận points)
  void doPrestige(Decimal totalEnergyEarned) {
    final gain = calculatePrestigeGain(totalEnergyEarned, prestigePoints);
    if (gain <= Decimal.zero) return;

    prestigePoints = NumberFormatter.toDecimal(prestigePoints + gain);
    prestigeCount++;
    lastPrestigeTime = DateTime.now();
  }

  /// Tiêu prestige points (mua prestige upgrades)
  bool spendPrestigePoints(Decimal amount) {
    if (prestigePoints < amount) return false;

    prestigePoints = NumberFormatter.toDecimal(prestigePoints - amount);
    prestigePointsSpent =
        NumberFormatter.toDecimal(prestigePointsSpent + amount);
    return true;
  }

  /// Reset toàn bộ prestige (cheat/debug)
  void resetAll() {
    prestigeCount = 0;
    prestigePoints = Decimal.zero;
    prestigePointsSpent = Decimal.zero;
    lastPrestigeTime = null;
  }

  // === Serialization ===

  Map<String, dynamic> toJson() {
    return {
      'prestigeCount': prestigeCount,
      'prestigePoints': prestigePoints.toString(),
      'prestigePointsSpent': prestigePointsSpent.toString(),
      'lastPrestigeTime': lastPrestigeTime?.toIso8601String(),
    };
  }

  factory PrestigeData.fromJson(Map<String, dynamic> json) {
    return PrestigeData(
      prestigeCount: json['prestigeCount'] as int? ?? 0,
      prestigePoints: json['prestigePoints'] != null
          ? Decimal.parse(json['prestigePoints'] as String)
          : Decimal.zero,
      prestigePointsSpent: json['prestigePointsSpent'] != null
          ? Decimal.parse(json['prestigePointsSpent'] as String)
          : Decimal.zero,
      lastPrestigeTime: json['lastPrestigeTime'] != null
          ? DateTime.parse(json['lastPrestigeTime'] as String)
          : null,
    );
  }

  PrestigeData copyWith({
    int? prestigeCount,
    Decimal? prestigePoints,
    Decimal? prestigePointsSpent,
    DateTime? lastPrestigeTime,
  }) {
    return PrestigeData(
      prestigeCount: prestigeCount ?? this.prestigeCount,
      prestigePoints: prestigePoints ?? this.prestigePoints,
      prestigePointsSpent: prestigePointsSpent ?? this.prestigePointsSpent,
      lastPrestigeTime: lastPrestigeTime ?? this.lastPrestigeTime,
    );
  }

  @override
  String toString() {
    return 'PrestigeData(count: $prestigeCount, points: $prestigePoints, multiplier: ${prestigeMultiplier.toStringAsFixed(2)}x)';
  }
}
