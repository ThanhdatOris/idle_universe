import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/core/config/game_config.dart';
import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/services/services.dart';
import 'package:idle_universe/core/utils/utils.dart';

/// ComprehensiveGameController - Game controller using core models
///
/// Quản lý:
/// - GameState với generators
/// - GameStats tracking
/// - PrestigeData
/// - Auto-save
/// - Offline progress
/// - Achievements
class ComprehensiveGameController extends Notifier<GameState> {
  Timer? _gameLoop;
  Timer? _autoClickTimer;
  SaveManager? _saveManager;
  GameStats? _stats;
  PrestigeData? _prestigeData;
  AchievementService? _achievementService;
  UpgradeService? _upgradeService;
  AudioService? _audioService;

  // Callback for achievement notifications
  void Function(Achievement)? _onAchievementUnlocked;

  // Offline reward data
  Map<String, dynamic>? _offlineRewardData;
  bool _offlineRewardShown = false;

  /// Set achievement unlock callback (called from UI)
  void setAchievementCallback(void Function(Achievement) callback) {
    _onAchievementUnlocked = callback;
  }

  @override
  GameState build() {
    _initializeGame();
    ref.onDispose(() {
      _gameLoop?.cancel();
      _autoClickTimer?.cancel();
      _saveManager?.dispose();
      _audioService?.stopBgm();
    });
    return _createInitialState();
  }

  /// Initialize game - load save data or create new game
  Future<void> _initializeGame() async {
    try {
      // Initialize audio service
      _audioService = AudioService();
      await _audioService!.initialize();
      _audioService!.playBgm('gameLoopTrack.mp3');

      // Initialize save manager
      _saveManager = await SaveManager.initialize(
        autoSaveInterval: Duration(seconds: GameConfig.autoSaveIntervalSeconds),
        onSaveSuccess: () {
          LoggerService.success('Game saved successfully');
        },
        onSaveError: (error) {
          LoggerService.error('Failed to save game', error);
        },
      );

      // Initialize achievement service
      _achievementService = AchievementService(
        onAchievementUnlocked: (achievement) {
          LoggerService.success('🏆 ${achievement.name} unlocked!');
          _audioService?.playSfx('achievement.wav');
          // Call UI callback if set
          _onAchievementUnlocked?.call(achievement);
        },
      );

      // Initialize upgrade service
      _upgradeService = UpgradeService();

      // Load saved data
      final saveData = await _saveManager!.loadCompleteGameData();

      final savedState = saveData['gameState'] as GameState?;
      final savedStats = saveData['stats'] as GameStats?;
      final savedPrestige = saveData['prestigeData'] as PrestigeData?;
      final savedAchievements = saveData['achievements'] as List<Achievement>?;
      final savedUpgrades = saveData['upgrades'] as List<Upgrade>?;

      if (savedState != null) {
        // Load upgrades FIRST so they affect offline progress
        if (savedUpgrades != null) {
          _upgradeService?.loadUpgrades(savedUpgrades);
        }

        // Load achievements
        if (savedAchievements != null) {
          _achievementService?.loadAchievements(savedAchievements);
        }

        // Apply offline progress
        final offlineService = OfflineProgressService(
          maxOfflineHours: GameConfig.offlineProgressCapHours,
          offlinePenalty: GameConfig.offlineProgressPenalty,
        );

        // Get multipliers for offline calculation
        // We need to temporarily set state to savedState to use _getGeneratorMultipliers
        // or just manually calculate them since state isn't set yet
        final generatorMultipliers = <String, double>{};
        if (_upgradeService != null) {
          for (final generator in savedState.generators) {
            final mult = _upgradeService!.getGeneratorMultiplier(generator.id);
            if (mult > 1.0) {
              generatorMultipliers[generator.id] = mult;
            }
          }
        }

        final stateWithOffline = offlineService.applyOfflineProgress(
          gameState: savedState,
          lastUpdateTime: savedState.lastUpdateTime,
          generatorMultipliers: generatorMultipliers,
        );

        state = stateWithOffline;
        _stats = savedStats ?? GameStats();
        _prestigeData = savedPrestige ?? PrestigeData();

        // Show offline reward if any
        final progress = offlineService.calculateOfflineProgress(
          gameState: savedState,
          lastUpdateTime: savedState.lastUpdateTime,
          generatorMultipliers: generatorMultipliers,
        );

        final offlineTime = progress['offlineTime'] as Duration;
        if (offlineTime.inMinutes > 1) {
          LoggerService.info(
            'Offline progress: ${offlineService.formatOfflineMessage(progress)}',
          );

          // Store offline reward data for UI
          _offlineRewardData = progress;
        }
      } else {
        // New game
        state = _createInitialState();
        _stats = GameStats();
        _prestigeData = PrestigeData();
      }

      // Start game loop and auto-save
      _startGameLoop();
      _updateAutoClickTimer(); // Restore auto-clicker if purchased
      _saveManager!.startAutoSave();
    } catch (e) {
      LoggerService.error('Error initializing game', e);
      state = _createInitialState();
      _stats = GameStats();
      _prestigeData = PrestigeData();
      _achievementService = AchievementService();
      _upgradeService = UpgradeService();
      _startGameLoop();
    }
  }

  /// Create initial game state with default generators
  GameState _createInitialState() {
    return GameState(
      generators: GameConfig.getDefaultGenerators(),
    );
  }

  /// Start game loop
  void _startGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(
      Duration(milliseconds: GameConfig.gameLoopTickMs),
      (timer) {
        _updateGameState();
      },
    );
  }

  /// Update game state every tick
  void _updateGameState() {
    // Update global multiplier from upgrades
    _updateMultipliers();

    // Get generator multipliers
    final generatorMultipliers = _getGeneratorMultipliers();

    final earned =
        state.updateEnergy(generatorMultipliers: generatorMultipliers);

    // IMPORTANT: Must reassign state to trigger Riverpod update
    if (earned > Decimal.zero) {
      state = state.copyWith();

      // Update stats
      _stats?.updateMaxEnergy(state.energy);
      _stats?.updateMaxEnergyPerSecond(_getEnergyPerSecondWithMultipliers());

      // Check achievements (every 5 seconds to avoid performance issues)
      if (DateTime.now().second % 5 == 0) {
        _checkAchievements();
      }

      // Trigger debounced save
      _saveManager?.saveDebounced(state);
    }
  }

  /// Update multipliers from upgrades
  void _updateMultipliers() {
    if (_upgradeService == null) return;

    // Update global multiplier in game state
    final globalMult = _upgradeService!.getGlobalMultiplier();
    if (state.globalMultiplier != globalMult) {
      state = state.copyWith(globalMultiplier: globalMult);
    }
  }

  /// Get energy per second with all multipliers applied
  Decimal _getEnergyPerSecondWithMultipliers() {
    if (_upgradeService == null) {
      return state.getEnergyPerSecond();
    }

    final generatorMultipliers = _getGeneratorMultipliers();
    return state.getEnergyPerSecond(generatorMultipliers: generatorMultipliers);
  }

  /// Helper to get generator multipliers map
  Map<String, double> _getGeneratorMultipliers() {
    if (_upgradeService == null) return {};

    final generatorMultipliers = <String, double>{};
    for (final generator in state.generators) {
      final mult = _upgradeService!.getGeneratorMultiplier(generator.id);
      if (mult > 1.0) {
        generatorMultipliers[generator.id] = mult;
      }
    }
    return generatorMultipliers;
  }

  /// Check achievements
  void _checkAchievements() {
    if (_achievementService == null || _stats == null) return;

    _achievementService!.checkAchievements(
      stats: _stats!,
      gameState: state,
      prestigeData: _prestigeData,
    );
  }

  // ========== GENERATOR ACTIONS ==========

  /// Purchase generator (buys as many as possible up to amount)
  /// Returns actual number purchased
  int purchaseGenerator(String generatorId, {int amount = 1}) {
    int purchased = 0;

    for (int i = 0; i < amount; i++) {
      final success = state.purchaseGenerator(generatorId, amount: 1);
      if (success) {
        purchased++;
      } else {
        break; // Can't afford more
      }
    }

    if (purchased > 0) {
      state = state.copyWith();
      _stats?.incrementGeneratorsPurchased(count: purchased);
      LoggerService.info('Purchased $purchased x $generatorId');
      _audioService?.playSfx('buy.wav');
    }

    return purchased;
  }

  /// Get generator by ID
  Generator? getGenerator(String id) {
    return state.getGenerator(id);
  }

  // ========== UPGRADE ACTIONS ==========

  /// Purchase upgrade
  bool purchaseUpgrade(String upgradeId) {
    if (_upgradeService == null) return false;

    final success = _upgradeService!.purchaseUpgrade(upgradeId, state);
    if (success) {
      state = state.copyWith();
      _stats?.incrementUpgradesPurchased();
      _audioService?.playSfx('upgrade.wav');

      // Update auto-click timer if auto-clicker upgrade purchased
      final upgrade = _upgradeService!.getUpgrade(upgradeId);
      if (upgrade?.type == UpgradeType.autoClicker) {
        _updateAutoClickTimer();
      }
    }
    return success;
  }

  /// Update auto-click timer based on current auto-click rate
  void _updateAutoClickTimer() {
    _autoClickTimer?.cancel();

    final autoClickRate = _upgradeService?.getAutoClickRate() ?? 0.0;
    if (autoClickRate > 0) {
      // Calculate interval: 1000ms / rate = ms per click
      final intervalMs = (1000 / autoClickRate).round();
      _autoClickTimer = Timer.periodic(
        Duration(milliseconds: intervalMs),
        (timer) {
          clickEnergy(); // Auto-click
        },
      );
      LoggerService.info('Auto-clicker started: $autoClickRate clicks/sec');
    }
  }

  // ========== MANUAL ACTIONS ==========

  /// Manual click to add energy
  void clickEnergy({Decimal? amount}) {
    final baseAmount = amount ?? GameConfig.manualClickEnergy;

    // Apply click power multiplier from upgrades
    final clickMultiplier = _upgradeService?.getClickPowerMultiplier() ?? 1.0;
    final clickMultiplierDecimal = Decimal.parse(clickMultiplier.toString());
    final finalAmount =
        NumberFormatter.toDecimal(baseAmount * clickMultiplierDecimal);

    state.addEnergy(finalAmount);
    state = state.copyWith();
    _stats?.incrementClicks();

    // Only play sound for manual clicks (not auto-clicker)
    if (amount == null) {
      _audioService?.playSfx('click.wav');
    }
  }

  // ========== PRESTIGE ==========

  /// Check if can prestige
  bool canPrestige() {
    if (_prestigeData == null) return false;
    return PrestigeData.canPrestige(
      state.totalEnergyEarned,
      _prestigeData!.prestigePoints,
    );
  }

  /// Calculate prestige gain
  Decimal calculatePrestigeGain() {
    if (_prestigeData == null) return Decimal.zero;
    return PrestigeData.calculatePrestigeGain(
      state.totalEnergyEarned,
      _prestigeData!.prestigePoints,
    );
  }

  /// Perform prestige
  void performPrestige() {
    if (!canPrestige()) return;

    _prestigeData?.doPrestige(state.totalEnergyEarned);
    state.reset();
    state = state.copyWith();
    _stats?.incrementPrestiges();
    _audioService?.playSfx('prestige.wav');

    LoggerService.success(
        'Prestige completed! Points: ${_prestigeData?.prestigePoints}');

    // Save immediately after prestige
    _saveManager?.saveNow(state);
  }

  // ========== SAVE/LOAD ==========

  /// Save game manually
  Future<bool> saveGame() async {
    if (_saveManager == null) return false;

    return await _saveManager!.saveCompleteGameData(
      gameState: state,
      stats: _stats,
      prestigeData: _prestigeData,
      achievements: _achievementService?.achievements,
      upgrades: _upgradeService?.upgrades,
    );
  }

  /// Reset game (hard reset)
  Future<void> resetGame() async {
    if (_saveManager == null) return;

    await _saveManager!.saveService.clearAllData();
    state = _createInitialState();
    _stats = GameStats();
    _prestigeData = PrestigeData();
    _achievementService?.resetAll();
    _upgradeService?.resetAll();

    LoggerService.info('Game reset completed');
  }

  // ========== GETTERS ==========

  GameStats? get stats => _stats;
  PrestigeData? get prestigeData => _prestigeData;
  AchievementService? get achievementService => _achievementService;
  UpgradeService? get upgradeService => _upgradeService;
  AudioService? get audioService => _audioService;
  Decimal get energy => state.energy;
  Decimal get energyPerSecond => _getEnergyPerSecondWithMultipliers();
  List<Generator> get generators => state.generators;

  /// Get offline reward data (null if no reward or already shown)
  Map<String, dynamic>? get offlineRewardData {
    if (_offlineRewardShown || _offlineRewardData == null) {
      return null;
    }
    return _offlineRewardData;
  }

  /// Mark offline reward as shown
  void markOfflineRewardShown() {
    _offlineRewardShown = true;
  }
}

/// Provider for comprehensive game controller
final comprehensiveGameControllerProvider =
    NotifierProvider<ComprehensiveGameController, GameState>(
  ComprehensiveGameController.new,
);
