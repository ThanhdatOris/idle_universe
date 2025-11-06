import 'package:decimal/decimal.dart';

/// Game balance constants - Các hằng số cân bằng game
/// Dựa trên GDD: Idle Universe Builder
class GameConstants {
  // === IDLE LOOP TIMING ===
  /// Tần suất cập nhật game state (ms)
  static const int idleTickMs = 100; // Update mỗi 100ms = 10 ticks/giây

  // === STARTING VALUES (Tier 1: Subatomic) ===
  static final Decimal startingEnergy = Decimal.zero;
  static final Decimal startingEnergyRate = Decimal.one; // 1 Energy/s
  static final Decimal startingMatter = Decimal.zero;
  static final Decimal startingMatterRate = Decimal.zero; // Chưa mở khóa

  // === UPGRADE COSTS & SCALING ===
  // Energy upgrade (tăng Energy/s)
  static final Decimal energyUpgradeBaseCost = Decimal.fromInt(10);
  static const double energyUpgradeCostMultiplier = 1.15; // Cost tăng 15% mỗi level
  static final Decimal energyUpgradeRateIncrease = Decimal.one; // +1 E/s mỗi upgrade

  // Matter producer (mở khóa Matter production)
  static final Decimal matterProducerBaseCost = Decimal.fromInt(100); // Chi phí bằng Energy
  static const double matterProducerCostMultiplier = 1.2; // Cost tăng 20%
  static final Decimal matterProducerRateIncrease = Decimal.one; // +1 M/s mỗi upgrade

  // === PRESTIGE SYSTEM ===
  static final Decimal firstPrestigeThreshold = Decimal.fromInt(1000); // Cần 1000 Entropy
  static const double prestigeDarkEnergyFormula = 0.1; // Dark Energy = sqrt(Entropy) * 0.1

  // === OFFLINE PROGRESSION ===
  static const int maxOfflineHours = 24; // Tối đa 24 giờ offline
  static const double offlineEfficiency = 0.5; // 50% hiệu suất khi offline

  // === TIER UNLOCK THRESHOLDS (dựa GDD) ===
  static final Map<String, Decimal> tierUnlockCosts = {
    'subatomic': Decimal.zero, // Tier 1: Mở sẵn
    'atomic': Decimal.fromInt(500), // Tier 2: 500 Matter
    'planetary': Decimal.fromInt(10000), // Tier 3: 10k Matter
    'galactic': Decimal.fromInt(1000000), // Tier 4: 1M Matter
    'cosmic': Decimal.fromInt(1000000000), // Tier 5: 1B Matter
  };

  // === UI/UX ===
  static const int maxDisplayDecimals = 2; // Số lẻ hiển thị (1.23)
  static const double animationDuration = 0.3; // Thời gian animation (giây)

  // === SAVE/LOAD ===
  static const String saveKey = 'idle_universe_save_v1';
  static const int autoSaveIntervalSeconds = 30; // Lưu tự động mỗi 30s
}
