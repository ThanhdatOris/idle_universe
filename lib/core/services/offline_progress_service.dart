import 'package:decimal/decimal.dart';
import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/utils/utils.dart';

/// OfflineProgressService - Tính toán tiến trình offline
///
/// Chức năng:
/// - Tính tài nguyên kiếm được khi offline
/// - Áp dụng penalty cho offline quá lâu
/// - Giới hạn thời gian offline tối đa
class OfflineProgressService {
  /// Thời gian offline tối đa được tính (giờ)
  /// Mặc định: 8 giờ
  final int maxOfflineHours;

  /// Hệ số giảm cho offline progress (0.0 - 1.0)
  /// 0.0 = không giảm, 0.5 = giảm 50%
  /// Mặc định: 0.1 (giảm 10%)
  final double offlinePenalty;

  /// Có áp dụng penalty không
  final bool applyPenalty;

  OfflineProgressService({
    this.maxOfflineHours = 8,
    this.offlinePenalty = 0.1,
    this.applyPenalty = true,
  });

  /// Calculate offline progress
  ///
  /// Returns: Map với các thông tin:
  /// - 'energyEarned': Decimal - Năng lượng kiếm được
  /// - 'offlineTime': Duration - Thời gian offline
  /// - 'cappedTime': Duration - Thời gian thực tế được tính (sau khi cap)
  /// - 'wasCapped': bool - Có bị giới hạn không
  Map<String, dynamic> calculateOfflineProgress({
    required GameState gameState,
    required DateTime lastUpdateTime,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final offlineTime = now.difference(lastUpdateTime);

    // Nếu không có thời gian offline, return 0
    if (offlineTime.inSeconds <= 0) {
      return {
        'energyEarned': Decimal.zero,
        'offlineTime': Duration.zero,
        'cappedTime': Duration.zero,
        'wasCapped': false,
      };
    }

    // Giới hạn thời gian offline
    final maxOfflineSeconds = maxOfflineHours * 3600;
    final actualSeconds = offlineTime.inSeconds;
    final cappedSeconds =
        actualSeconds > maxOfflineSeconds ? maxOfflineSeconds : actualSeconds;
    final wasCapped = actualSeconds > maxOfflineSeconds;

    // Tính energy per second
    final energyPerSecond = gameState.getEnergyPerSecond();

    // Tính tổng energy kiếm được
    var energyEarned = NumberFormatter.toDecimal(
      energyPerSecond * Decimal.fromInt(cappedSeconds),
    );

    // Áp dụng penalty nếu cần
    if (applyPenalty && offlinePenalty > 0) {
      final penaltyMultiplier =
          Decimal.parse((1.0 - offlinePenalty).toString());
      energyEarned =
          NumberFormatter.toDecimal(energyEarned * penaltyMultiplier);
    }

    return {
      'energyEarned': energyEarned,
      'offlineTime': offlineTime,
      'cappedTime': Duration(seconds: cappedSeconds),
      'wasCapped': wasCapped,
    };
  }

  /// Apply offline progress to game state
  ///
  /// Returns: Updated GameState
  GameState applyOfflineProgress({
    required GameState gameState,
    required DateTime lastUpdateTime,
    DateTime? currentTime,
  }) {
    final progress = calculateOfflineProgress(
      gameState: gameState,
      lastUpdateTime: lastUpdateTime,
      currentTime: currentTime,
    );

    final energyEarned = progress['energyEarned'] as Decimal;

    if (energyEarned <= Decimal.zero) {
      return gameState;
    }

    // Update game state
    final newEnergy = NumberFormatter.toDecimal(
      gameState.energy + energyEarned,
    );
    final newTotalEarned = NumberFormatter.toDecimal(
      gameState.totalEnergyEarned + energyEarned,
    );

    return gameState.copyWith(
      energy: newEnergy,
      totalEnergyEarned: newTotalEarned,
      lastUpdateTime: currentTime ?? DateTime.now(),
    );
  }

  /// Format offline progress message
  String formatOfflineMessage(Map<String, dynamic> progress) {
    final energyEarned = progress['energyEarned'] as Decimal;
    final offlineTime = progress['offlineTime'] as Duration;
    final wasCapped = progress['wasCapped'] as bool;

    final hours = offlineTime.inHours;
    final minutes = (offlineTime.inMinutes % 60);

    String timeString;
    if (hours > 0) {
      timeString = '${hours}h ${minutes}m';
    } else {
      timeString = '${minutes}m';
    }

    String message = 'Welcome back!\n\n'
        'You were away for $timeString\n'
        'Energy earned: ${NumberFormatter.format(energyEarned)}';

    if (wasCapped) {
      message += '\n\n(Offline progress capped at $maxOfflineHours hours)';
    }

    if (applyPenalty && offlinePenalty > 0) {
      final penaltyPercent = (offlinePenalty * 100).toStringAsFixed(0);
      message += '\n(Offline penalty: -$penaltyPercent%)';
    }

    return message;
  }

  /// Get offline bonus multiplier (for upgrades)
  ///
  /// Một số upgrade có thể tăng offline production
  double getOfflineBonusMultiplier({
    List<Upgrade>? upgrades,
    PrestigeData? prestigeData,
  }) {
    double multiplier = 1.0;

    // TODO: Implement upgrade-based bonuses
    // Ví dụ: Nếu có upgrade "Offline Boost", tăng multiplier

    // TODO: Implement prestige-based bonuses
    // Ví dụ: Mỗi prestige tăng offline production 5%

    return multiplier;
  }

  /// Calculate offline progress with bonuses
  Map<String, dynamic> calculateOfflineProgressWithBonuses({
    required GameState gameState,
    required DateTime lastUpdateTime,
    DateTime? currentTime,
    List<Upgrade>? upgrades,
    PrestigeData? prestigeData,
  }) {
    final baseProgress = calculateOfflineProgress(
      gameState: gameState,
      lastUpdateTime: lastUpdateTime,
      currentTime: currentTime,
    );

    final bonusMultiplier = getOfflineBonusMultiplier(
      upgrades: upgrades,
      prestigeData: prestigeData,
    );

    if (bonusMultiplier != 1.0) {
      final baseEnergy = baseProgress['energyEarned'] as Decimal;
      final bonusMultiplierDecimal = Decimal.parse(bonusMultiplier.toString());
      final boostedEnergy = NumberFormatter.toDecimal(
        baseEnergy * bonusMultiplierDecimal,
      );

      baseProgress['energyEarned'] = boostedEnergy;
      baseProgress['bonusMultiplier'] = bonusMultiplier;
    }

    return baseProgress;
  }
}

/// OfflineRewardDialog data
class OfflineReward {
  final Decimal energyEarned;
  final Duration offlineTime;
  final Duration cappedTime;
  final bool wasCapped;
  final double? bonusMultiplier;

  OfflineReward({
    required this.energyEarned,
    required this.offlineTime,
    required this.cappedTime,
    required this.wasCapped,
    this.bonusMultiplier,
  });

  factory OfflineReward.fromProgress(Map<String, dynamic> progress) {
    return OfflineReward(
      energyEarned: progress['energyEarned'] as Decimal,
      offlineTime: progress['offlineTime'] as Duration,
      cappedTime: progress['cappedTime'] as Duration,
      wasCapped: progress['wasCapped'] as bool,
      bonusMultiplier: progress['bonusMultiplier'] as double?,
    );
  }

  String get formattedTime {
    final hours = offlineTime.inHours;
    final minutes = (offlineTime.inMinutes % 60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedEnergy {
    return NumberFormatter.format(energyEarned);
  }
}
