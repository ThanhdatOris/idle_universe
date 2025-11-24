import 'package:decimal/decimal.dart';
import 'package:idle_universe/core/models/models.dart';

/// GameConfig - Centralized game configuration and balance data
///
/// Contains all game constants, balance values, and initial data
class GameConfig {
  // ========== GAME CONSTANTS ==========

  /// Game loop tick rate (milliseconds)
  static const int gameLoopTickMs = 100;

  /// Auto-save interval (seconds)
  static const int autoSaveIntervalSeconds = 30;

  /// Offline progress cap (hours)
  static const int offlineProgressCapHours = 8;

  /// Offline progress penalty (0.0 - 1.0)
  static const double offlineProgressPenalty = 0.1;

  /// Manual click energy gain
  static final Decimal manualClickEnergy = Decimal.one;

  // ========== PRESTIGE CONSTANTS ==========

  /// Minimum energy for first prestige
  static final Decimal minPrestigeEnergy = Decimal.fromInt(1000000);

  /// Prestige formula exponent
  static const double prestigeExponent = 0.5;

  /// Prestige formula divisor
  static final Decimal prestigeDivisor = Decimal.fromInt(1000000);

  // ========== GENERATORS CONFIGURATION ==========

  /// Get default generators for new game
  static List<Generator> getDefaultGenerators() {
    return [
      // Tier 1: Subatomic
      Generator(
        id: 'gen_photon',
        name: 'Photon Collector',
        description: 'Captures light particles for basic energy',
        baseCost: Decimal.fromInt(10),
        baseProduction: Decimal.one,
        costMultiplier: 1.15,
        icon: '💡',
      ),
      Generator(
        id: 'gen_electron',
        name: 'Electron Harvester',
        description: 'Extracts energy from electron flow',
        baseCost: Decimal.fromInt(100),
        baseProduction: Decimal.fromInt(5),
        costMultiplier: 1.15,
        icon: '⚡',
      ),
      Generator(
        id: 'gen_quark',
        name: 'Quark Synthesizer',
        description: 'Manipulates fundamental particles',
        baseCost: Decimal.fromInt(1000),
        baseProduction: Decimal.fromInt(25),
        costMultiplier: 1.15,
        icon: '🔬',
      ),

      // Tier 2: Atomic
      Generator(
        id: 'gen_atom',
        name: 'Atomic Reactor',
        description: 'Nuclear fission for massive energy',
        baseCost: Decimal.fromInt(10000),
        baseProduction: Decimal.fromInt(100),
        costMultiplier: 1.15,
        icon: '⚛️',
      ),
      Generator(
        id: 'gen_molecule',
        name: 'Molecular Assembler',
        description: 'Combines atoms for efficient production',
        baseCost: Decimal.fromInt(100000),
        baseProduction: Decimal.fromInt(500),
        costMultiplier: 1.15,
        icon: '🧬',
      ),

      // Tier 3: Stellar
      Generator(
        id: 'gen_solar',
        name: 'Solar Harvester',
        description: 'Harness the power of stars',
        baseCost: Decimal.fromInt(1000000),
        baseProduction: Decimal.fromInt(2500),
        costMultiplier: 1.15,
        icon: '☀️',
      ),
      Generator(
        id: 'gen_fusion',
        name: 'Fusion Core',
        description: 'Advanced fusion technology',
        baseCost: Decimal.fromInt(10000000),
        baseProduction: Decimal.fromInt(12500),
        costMultiplier: 1.15,
        icon: '🔥',
      ),

      // Tier 4: Galactic
      Generator(
        id: 'gen_blackhole',
        name: 'Black Hole Engine',
        description: 'Extract energy from singularities',
        baseCost: Decimal.fromInt(100000000),
        baseProduction: Decimal.fromInt(62500),
        costMultiplier: 1.15,
        icon: '🕳️',
      ),
      Generator(
        id: 'gen_pulsar',
        name: 'Pulsar Array',
        description: 'Harness neutron star rotation',
        baseCost: Decimal.fromInt(1000000000),
        baseProduction: Decimal.fromInt(312500),
        costMultiplier: 1.15,
        icon: '🌟',
      ),

      // Tier 5: Universal
      Generator(
        id: 'gen_quantum',
        name: 'Quantum Generator',
        description: 'Quantum energy extraction',
        baseCost: Decimal.parse('10000000000'),
        baseProduction: Decimal.fromInt(1562500),
        costMultiplier: 1.15,
        icon: '🔮',
      ),
      Generator(
        id: 'gen_darkmatter',
        name: 'Dark Matter Converter',
        description: 'Convert dark matter to energy',
        baseCost: Decimal.parse('100000000000'),
        baseProduction: Decimal.fromInt(7812500),
        costMultiplier: 1.15,
        icon: '🌌',
      ),

      // Tier 6: Cosmic
      Generator(
        id: 'gen_bigbang',
        name: 'Big Bang Simulator',
        description: 'Recreate the birth of universes',
        baseCost: Decimal.parse('1000000000000'),
        baseProduction: Decimal.fromInt(39062500),
        costMultiplier: 1.15,
        icon: '💥',
      ),
    ];
  }

  // ========== ACHIEVEMENTS CONFIGURATION ==========

  /// Get default achievements
  static List<Achievement> getDefaultAchievements() {
    return [
      // Energy milestones
      Achievement(
        id: 'ach_energy_100',
        name: 'Getting Started',
        description: 'Earn 100 total energy',
        type: AchievementType.totalEnergy,
        targetValue: 100.0,
        icon: '🌱',
        reward: {'prestigePoints': 10.0},
      ),
      Achievement(
        id: 'ach_energy_1k',
        name: 'Energy Enthusiast',
        description: 'Earn 1,000 total energy',
        type: AchievementType.totalEnergy,
        targetValue: 1000.0,
        icon: '⚡',
        reward: {'prestigePoints': 50.0},
      ),
      Achievement(
        id: 'ach_energy_1m',
        name: 'Energy Master',
        description: 'Earn 1,000,000 total energy',
        type: AchievementType.totalEnergy,
        targetValue: 1000000.0,
        icon: '💫',
        reward: {'prestigePoints': 1000.0},
      ),

      // Click achievements
      Achievement(
        id: 'ach_clicks_100',
        name: 'Clicker',
        description: 'Click 100 times',
        type: AchievementType.totalClicks,
        targetValue: 100.0,
        icon: '👆',
        reward: {'prestigePoints': 10.0},
      ),
      Achievement(
        id: 'ach_clicks_1k',
        name: 'Dedicated Clicker',
        description: 'Click 1,000 times',
        type: AchievementType.totalClicks,
        targetValue: 1000.0,
        icon: '👆👆',
        reward: {'prestigePoints': 100.0},
      ),

      // Generator achievements
      Achievement(
        id: 'ach_gen_first',
        name: 'First Generator',
        description: 'Purchase your first generator',
        type: AchievementType.totalGenerators,
        targetValue: 1.0,
        icon: '🏭',
        reward: {'prestigePoints': 5.0},
      ),
      Achievement(
        id: 'ach_gen_100',
        name: 'Factory Owner',
        description: 'Purchase 100 generators',
        type: AchievementType.totalGenerators,
        targetValue: 100.0,
        icon: '🏭🏭',
        reward: {'prestigePoints': 500.0},
      ),

      // Prestige achievements
      Achievement(
        id: 'ach_prestige_first',
        name: 'First Prestige',
        description: 'Prestige for the first time',
        type: AchievementType.prestigeCount,
        targetValue: 1.0,
        icon: '⭐',
        reward: {'prestigePoints': 100.0},
      ),
      Achievement(
        id: 'ach_prestige_10',
        name: 'Prestige Master',
        description: 'Prestige 10 times',
        type: AchievementType.prestigeCount,
        targetValue: 10.0,
        icon: '⭐⭐⭐',
        reward: {'prestigePoints': 1000.0},
      ),
    ];
  }

  // ========== UPGRADES CONFIGURATION ==========

  /// Get default upgrades
  static List<Upgrade> getDefaultUpgrades() {
    return [
      // Click power upgrades
      Upgrade(
        id: 'upg_click_2x',
        name: 'Better Clicking',
        description: 'Double click power',
        cost: Decimal.fromInt(100),
        type: UpgradeType.clickPower,
        effectValue: 2.0,
        icon: '👆',
      ),
      Upgrade(
        id: 'upg_click_5x',
        name: 'Super Clicking',
        description: '5x click power',
        cost: Decimal.fromInt(10000),
        type: UpgradeType.clickPower,
        effectValue: 5.0,
        icon: '👆💪',
        requirementId: 'upg_click_2x',
      ),

      // Global multiplier upgrades
      Upgrade(
        id: 'upg_global_2x',
        name: 'Efficiency I',
        description: '2x all production',
        cost: Decimal.fromInt(1000),
        type: UpgradeType.globalMultiplier,
        effectValue: 2.0,
        icon: '📈',
      ),
      Upgrade(
        id: 'upg_global_3x',
        name: 'Efficiency II',
        description: '3x all production',
        cost: Decimal.fromInt(100000),
        type: UpgradeType.globalMultiplier,
        effectValue: 3.0,
        icon: '📈📈',
        requirementId: 'upg_global_2x',
      ),

      // Generator-specific upgrades
      Upgrade(
        id: 'upg_photon_2x',
        name: 'Enhanced Photons',
        description: '2x Photon Collector production',
        cost: Decimal.fromInt(500),
        type: UpgradeType.generatorMultiplier,
        effectValue: 2.0,
        targetId: 'gen_photon',
        icon: '💡⚡',
      ),
      Upgrade(
        id: 'upg_electron_2x',
        name: 'Enhanced Electrons',
        description: '2x Electron Harvester production',
        cost: Decimal.fromInt(5000),
        type: UpgradeType.generatorMultiplier,
        effectValue: 2.0,
        targetId: 'gen_electron',
        icon: '⚡⚡',
      ),
    ];
  }

  // ========== UI CONFIGURATION ==========

  /// Resource display colors
  static const Map<String, int> resourceColors = {
    'energy': 0xFFFFC107, // Amber
    'matter': 0xFF9C27B0, // Purple
    'entropy': 0xFFFF5722, // Deep Orange
    'darkEnergy': 0xFF673AB7, // Deep Purple
  };

  /// Generator tier colors
  static const List<int> generatorTierColors = [
    0xFFFFC107, // Amber - Tier 1
    0xFFFF9800, // Orange - Tier 2
    0xFF9C27B0, // Purple - Tier 3
    0xFF2196F3, // Blue - Tier 4
    0xFF00BCD4, // Cyan - Tier 5
    0xFF4CAF50, // Green - Tier 6
  ];
}
