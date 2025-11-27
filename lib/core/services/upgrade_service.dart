import 'package:idle_universe/core/config/game_config.dart';
import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/services/services.dart';

/// UpgradeService - Manages upgrades and their effects
///
/// Chức năng:
/// - Track purchased upgrades
/// - Calculate upgrade effects
/// - Check upgrade requirements
/// - Apply upgrade bonuses
class UpgradeService {
  List<Upgrade> _upgrades = [];

  UpgradeService() {
    _upgrades = GameConfig.getDefaultUpgrades();
  }

  /// Get all upgrades
  List<Upgrade> get upgrades => _upgrades;

  /// Get purchased upgrades
  List<Upgrade> get purchasedUpgrades =>
      _upgrades.where((u) => u.isPurchased).toList();

  /// Get available upgrades (not purchased, requirements met)
  List<Upgrade> getAvailableUpgrades() {
    return _upgrades.where((u) {
      if (u.isPurchased) return false;

      // Check if requirement is met
      if (u.requirementId != null) {
        final requirement = getUpgrade(u.requirementId!);
        if (requirement == null || !requirement.isPurchased) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get locked upgrades (requirements not met)
  List<Upgrade> getLockedUpgrades() {
    return _upgrades.where((u) {
      if (u.isPurchased) return false;

      if (u.requirementId != null) {
        final requirement = getUpgrade(u.requirementId!);
        if (requirement == null || !requirement.isPurchased) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  /// Get upgrade by ID
  Upgrade? getUpgrade(String id) {
    try {
      return _upgrades.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Purchase upgrade
  bool purchaseUpgrade(String upgradeId, GameState gameState) {
    final upgrade = getUpgrade(upgradeId);
    if (upgrade == null) return false;

    // Check if can afford
    if (!gameState.canAfford(upgrade.cost)) {
      LoggerService.warning('Cannot afford upgrade: ${upgrade.name}');
      return false;
    }

    // Check requirements
    if (!upgrade.canPurchase(_upgrades)) {
      LoggerService.warning('Requirements not met for: ${upgrade.name}');
      return false;
    }

    // Purchase
    upgrade.purchase();
    gameState.spendEnergy(upgrade.cost);
    LoggerService.success('Purchased upgrade: ${upgrade.name}');
    return true;
  }

  /// Get total multiplier for a specific type
  double getMultiplier(UpgradeType type, {String? targetId}) {
    double multiplier = 1.0;

    for (final upgrade in purchasedUpgrades) {
      if (upgrade.type == type) {
        // For generator-specific upgrades, check target ID
        if (type == UpgradeType.generatorMultiplier) {
          if (upgrade.targetId == targetId) {
            multiplier *= upgrade.effectValue;
          }
        } else {
          multiplier *= upgrade.effectValue;
        }
      }
    }

    return multiplier;
  }

  /// Get click power multiplier
  double getClickPowerMultiplier() {
    return getMultiplier(UpgradeType.clickPower);
  }

  /// Get global production multiplier
  double getGlobalMultiplier() {
    return getMultiplier(UpgradeType.globalMultiplier);
  }

  /// Get generator-specific multiplier
  double getGeneratorMultiplier(String generatorId) {
    return getMultiplier(UpgradeType.generatorMultiplier,
        targetId: generatorId);
  }

  /// Get auto-click rate (clicks per second)
  double getAutoClickRate() {
    double totalRate = 0.0;
    for (final upgrade in purchasedUpgrades) {
      if (upgrade.type == UpgradeType.autoClicker) {
        totalRate += upgrade.effectValue;
      }
    }
    return totalRate;
  }

  /// Get all active multipliers
  Map<String, double> getAllMultipliers() {
    return {
      'clickPower': getClickPowerMultiplier(),
      'global': getGlobalMultiplier(),
      'autoClickRate': getAutoClickRate(),
    };
  }

  /// Get upgrades by type
  List<Upgrade> getUpgradesByType(UpgradeType type) {
    return _upgrades.where((u) => u.type == type).toList();
  }

  /// Load upgrades from saved data
  void loadUpgrades(List<Upgrade> savedUpgrades) {
    // Merge saved state with default upgrades
    for (final saved in savedUpgrades) {
      final index = _upgrades.indexWhere((u) => u.id == saved.id);
      if (index != -1) {
        _upgrades[index] = saved;
      }
    }
  }

  /// Reset all upgrades (for prestige)
  void resetForPrestige() {
    for (final upgrade in _upgrades) {
      upgrade.reset();
    }
  }

  /// Reset all upgrades (for hard reset)
  void resetAll() {
    _upgrades = GameConfig.getDefaultUpgrades();
  }

  /// Get upgrade statistics
  Map<String, dynamic> getStatistics() {
    final total = _upgrades.length;
    final purchased = purchasedUpgrades.length;
    final available = getAvailableUpgrades().length;
    final locked = getLockedUpgrades().length;

    return {
      'total': total,
      'purchased': purchased,
      'available': available,
      'locked': locked,
      'percentage':
          total > 0 ? (purchased / total * 100).toStringAsFixed(1) : '0.0',
    };
  }
}
