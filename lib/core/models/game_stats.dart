import 'package:decimal/decimal.dart';

/// Stats model - Thống kê game
///
/// Lưu trữ các số liệu:
/// - Tổng clicks, runtime
/// - Max energy đạt được
/// - Số generators/upgrades đã mua
class GameStats {
  /// Tổng số lần click manual
  int totalClicks;

  /// Tổng thời gian chơi (giây)
  int totalPlayTimeSeconds;

  /// Max energy đã đạt được
  Decimal maxEnergy;

  /// Max energy per second
  Decimal maxEnergyPerSecond;

  /// Tổng số generators đã mua (lifetime)
  int totalGeneratorsPurchased;

  /// Tổng số upgrades đã mua (lifetime)
  int totalUpgradesPurchased;

  /// Số lần prestige
  int totalPrestiges;

  /// Thời gian bắt đầu session hiện tại
  DateTime sessionStartTime;

  /// Thời gian tạo save đầu tiên
  DateTime? firstPlayTime;

  GameStats({
    this.totalClicks = 0,
    this.totalPlayTimeSeconds = 0,
    Decimal? maxEnergy,
    Decimal? maxEnergyPerSecond,
    this.totalGeneratorsPurchased = 0,
    this.totalUpgradesPurchased = 0,
    this.totalPrestiges = 0,
    DateTime? sessionStartTime,
    this.firstPlayTime,
  })  : maxEnergy = maxEnergy ?? Decimal.zero,
        maxEnergyPerSecond = maxEnergyPerSecond ?? Decimal.zero,
        sessionStartTime = sessionStartTime ?? DateTime.now();

  /// Cập nhật max energy nếu cao hơn
  void updateMaxEnergy(Decimal currentEnergy) {
    if (currentEnergy > maxEnergy) {
      maxEnergy = currentEnergy;
    }
  }

  /// Cập nhật max energy per second
  void updateMaxEnergyPerSecond(Decimal currentEnergyPerSecond) {
    if (currentEnergyPerSecond > maxEnergyPerSecond) {
      maxEnergyPerSecond = currentEnergyPerSecond;
    }
  }

  /// Thêm click
  void incrementClicks({int count = 1}) {
    totalClicks += count;
  }

  /// Thêm generator purchased
  void incrementGeneratorsPurchased({int count = 1}) {
    totalGeneratorsPurchased += count;
  }

  /// Thêm upgrade purchased
  void incrementUpgradesPurchased() {
    totalUpgradesPurchased++;
  }

  /// Thêm prestige
  void incrementPrestiges() {
    totalPrestiges++;
  }

  /// Cập nhật play time (gọi định kỳ hoặc khi save)
  void updatePlayTime() {
    final currentSession =
        DateTime.now().difference(sessionStartTime).inSeconds;
    totalPlayTimeSeconds += currentSession;
    sessionStartTime = DateTime.now(); // Reset session
  }

  /// Get play time formatted (h:m:s)
  String getFormattedPlayTime() {
    final hours = totalPlayTimeSeconds ~/ 3600;
    final minutes = (totalPlayTimeSeconds % 3600) ~/ 60;
    final seconds = totalPlayTimeSeconds % 60;
    return '${hours}h ${minutes}m ${seconds}s';
  }

  /// Reset một số stats (khi prestige)
  void resetForPrestige() {
    // Giữ lại lifetime stats, chỉ reset current session
    sessionStartTime = DateTime.now();
  }

  /// Reset toàn bộ (hard reset)
  void resetAll() {
    totalClicks = 0;
    totalPlayTimeSeconds = 0;
    maxEnergy = Decimal.zero;
    maxEnergyPerSecond = Decimal.zero;
    totalGeneratorsPurchased = 0;
    totalUpgradesPurchased = 0;
    totalPrestiges = 0;
    sessionStartTime = DateTime.now();
    firstPlayTime = null;
  }

  // === Serialization ===

  Map<String, dynamic> toJson() {
    return {
      'totalClicks': totalClicks,
      'totalPlayTimeSeconds': totalPlayTimeSeconds,
      'maxEnergy': maxEnergy.toString(),
      'maxEnergyPerSecond': maxEnergyPerSecond.toString(),
      'totalGeneratorsPurchased': totalGeneratorsPurchased,
      'totalUpgradesPurchased': totalUpgradesPurchased,
      'totalPrestiges': totalPrestiges,
      'sessionStartTime': sessionStartTime.toIso8601String(),
      'firstPlayTime': firstPlayTime?.toIso8601String(),
    };
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalClicks: json['totalClicks'] as int? ?? 0,
      totalPlayTimeSeconds: json['totalPlayTimeSeconds'] as int? ?? 0,
      maxEnergy: json['maxEnergy'] != null
          ? Decimal.parse(json['maxEnergy'] as String)
          : Decimal.zero,
      maxEnergyPerSecond: json['maxEnergyPerSecond'] != null
          ? Decimal.parse(json['maxEnergyPerSecond'] as String)
          : Decimal.zero,
      totalGeneratorsPurchased: json['totalGeneratorsPurchased'] as int? ?? 0,
      totalUpgradesPurchased: json['totalUpgradesPurchased'] as int? ?? 0,
      totalPrestiges: json['totalPrestiges'] as int? ?? 0,
      sessionStartTime: json['sessionStartTime'] != null
          ? DateTime.parse(json['sessionStartTime'] as String)
          : DateTime.now(),
      firstPlayTime: json['firstPlayTime'] != null
          ? DateTime.parse(json['firstPlayTime'] as String)
          : null,
    );
  }

  GameStats copyWith({
    int? totalClicks,
    int? totalPlayTimeSeconds,
    Decimal? maxEnergy,
    Decimal? maxEnergyPerSecond,
    int? totalGeneratorsPurchased,
    int? totalUpgradesPurchased,
    int? totalPrestiges,
    DateTime? sessionStartTime,
    DateTime? firstPlayTime,
  }) {
    return GameStats(
      totalClicks: totalClicks ?? this.totalClicks,
      totalPlayTimeSeconds: totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      maxEnergyPerSecond: maxEnergyPerSecond ?? this.maxEnergyPerSecond,
      totalGeneratorsPurchased:
          totalGeneratorsPurchased ?? this.totalGeneratorsPurchased,
      totalUpgradesPurchased:
          totalUpgradesPurchased ?? this.totalUpgradesPurchased,
      totalPrestiges: totalPrestiges ?? this.totalPrestiges,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      firstPlayTime: firstPlayTime ?? this.firstPlayTime,
    );
  }

  @override
  String toString() {
    return 'GameStats(clicks: $totalClicks, playtime: ${getFormattedPlayTime()}, prestiges: $totalPrestiges)';
  }
}
