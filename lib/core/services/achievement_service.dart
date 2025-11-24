import 'package:idle_universe/core/config/game_config.dart';
import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/services/services.dart';

/// AchievementService - Manages achievement tracking and unlocking
///
/// Chức năng:
/// - Track progress towards achievements
/// - Auto-unlock when conditions met
/// - Notify when achievements unlock
/// - Save/load achievement state
class AchievementService {
  List<Achievement> _achievements = [];
  final void Function(Achievement)? onAchievementUnlocked;

  AchievementService({
    this.onAchievementUnlocked,
  }) {
    _achievements = GameConfig.getDefaultAchievements();
  }

  /// Get all achievements
  List<Achievement> get achievements => _achievements;

  /// Get unlocked achievements
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();

  /// Get locked achievements
  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();

  /// Get achievement by ID
  Achievement? getAchievement(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check and unlock achievements based on game state
  List<Achievement> checkAchievements({
    required GameStats stats,
    required GameState gameState,
    required PrestigeData? prestigeData,
  }) {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      final currentValue = _getCurrentValue(
        achievement.type,
        stats: stats,
        gameState: gameState,
        prestigeData: prestigeData,
      );

      if (achievement.checkUnlock(currentValue)) {
        achievement.unlock();
        newlyUnlocked.add(achievement);
        onAchievementUnlocked?.call(achievement);
        LoggerService.success(
          'Achievement unlocked: ${achievement.name}',
          'Achievements',
        );
      }
    }

    return newlyUnlocked;
  }

  /// Get current value for achievement type
  double _getCurrentValue(
    AchievementType type, {
    required GameStats stats,
    required GameState gameState,
    required PrestigeData? prestigeData,
  }) {
    switch (type) {
      case AchievementType.totalEnergy:
        return gameState.totalEnergyEarned.toDouble();

      case AchievementType.totalClicks:
        return stats.totalClicks.toDouble();

      case AchievementType.totalGenerators:
        return stats.totalGeneratorsPurchased.toDouble();

      case AchievementType.prestigeCount:
        return (prestigeData?.prestigeCount ?? 0).toDouble();

      case AchievementType.energyPerSecond:
        return gameState.getEnergyPerSecond().toDouble();

      case AchievementType.totalUpgrades:
        return stats.totalUpgradesPurchased.toDouble();

      case AchievementType.playTime:
        return (stats.totalPlayTimeSeconds / 3600)
            .toDouble(); // Convert to hours

      case AchievementType.special:
        return 0.0; // Special achievements handled separately
    }
  }

  /// Get progress for an achievement
  double getProgress(
    String achievementId, {
    required GameStats stats,
    required GameState gameState,
    required PrestigeData? prestigeData,
  }) {
    final achievement = getAchievement(achievementId);
    if (achievement == null) return 0.0;

    final currentValue = _getCurrentValue(
      achievement.type,
      stats: stats,
      gameState: gameState,
      prestigeData: prestigeData,
    );

    return achievement.getProgress(currentValue);
  }

  /// Load achievements from saved data
  void loadAchievements(List<Achievement> savedAchievements) {
    // Merge saved state with default achievements
    for (final saved in savedAchievements) {
      final index = _achievements.indexWhere((a) => a.id == saved.id);
      if (index != -1) {
        _achievements[index] = saved;
      }
    }
  }

  /// Reset all achievements (for hard reset)
  void resetAll() {
    _achievements = GameConfig.getDefaultAchievements();
  }

  /// Get achievement statistics
  Map<String, dynamic> getStatistics() {
    final total = _achievements.length;
    final unlocked = unlockedAchievements.length;
    final percentage =
        total > 0 ? (unlocked / total * 100).toStringAsFixed(1) : '0.0';

    return {
      'total': total,
      'unlocked': unlocked,
      'locked': total - unlocked,
      'percentage': percentage,
    };
  }

  /// Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  /// Get recently unlocked achievements (last N)
  List<Achievement> getRecentlyUnlocked({int count = 5}) {
    final unlocked = unlockedAchievements;
    unlocked.sort((a, b) {
      if (a.unlockedAt == null) return 1;
      if (b.unlockedAt == null) return -1;
      return b.unlockedAt!.compareTo(a.unlockedAt!);
    });
    return unlocked.take(count).toList();
  }
}
