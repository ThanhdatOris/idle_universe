import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/services/services.dart';

/// ComprehensiveGameController - Game controller using core models
///
/// Quản lý:
/// - GameState với generators
/// - GameStats tracking
/// - PrestigeData
/// - Auto-save
/// - Offline progress
class ComprehensiveGameController extends Notifier<GameState> {
  Timer? _gameLoop;
  SaveManager? _saveManager;
  GameStats? _stats;
  PrestigeData? _prestigeData;

  @override
  GameState build() {
    _initializeGame();
    ref.onDispose(() {
      _gameLoop?.cancel();
      _saveManager?.dispose();
    });
    return _createInitialState();
  }

  /// Initialize game - load save data or create new game
  Future<void> _initializeGame() async {
    try {
      // Initialize save manager
      _saveManager = await SaveManager.initialize(
        autoSaveInterval: const Duration(seconds: 30),
        onSaveSuccess: () {
          LoggerService.success('Game saved successfully');
        },
        onSaveError: (error) {
          LoggerService.error('Failed to save game', error);
        },
      );

      // Load saved data
      final saveData = await _saveManager!.loadCompleteGameData();

      final savedState = saveData['gameState'] as GameState?;
      final savedStats = saveData['stats'] as GameStats?;
      final savedPrestige = saveData['prestigeData'] as PrestigeData?;

      if (savedState != null) {
        // Apply offline progress
        final offlineService = OfflineProgressService();
        final stateWithOffline = offlineService.applyOfflineProgress(
          gameState: savedState,
          lastUpdateTime: savedState.lastUpdateTime,
        );

        state = stateWithOffline;
        _stats = savedStats ?? GameStats();
        _prestigeData = savedPrestige ?? PrestigeData();

        // Show offline reward if any
        final progress = offlineService.calculateOfflineProgress(
          gameState: savedState,
          lastUpdateTime: savedState.lastUpdateTime,
        );

        final offlineTime = progress['offlineTime'] as Duration;
        if (offlineTime.inMinutes > 1) {
          LoggerService.info(
            'Offline progress: ${offlineService.formatOfflineMessage(progress)}',
          );
        }
      } else {
        // New game
        state = _createInitialState();
        _stats = GameStats();
        _prestigeData = PrestigeData();
      }

      // Start game loop and auto-save
      _startGameLoop();
      _saveManager!.startAutoSave();
    } catch (e) {
      LoggerService.error('Error initializing game', e);
      state = _createInitialState();
      _stats = GameStats();
      _prestigeData = PrestigeData();
      _startGameLoop();
    }
  }

  /// Create initial game state with default generators
  GameState _createInitialState() {
    return GameState(
      generators: _createDefaultGenerators(),
    );
  }

  /// Create default generators for new game
  List<Generator> _createDefaultGenerators() {
    return [
      Generator(
        id: 'energy_gen_1',
        name: 'Energy Collector',
        description: 'Basic energy collection device',
        baseCost: Decimal.fromInt(10),
        baseProduction: Decimal.one,
        costMultiplier: 1.15,
        icon: '⚡',
      ),
      Generator(
        id: 'energy_gen_2',
        name: 'Solar Panel',
        description: 'Harness energy from stars',
        baseCost: Decimal.fromInt(100),
        baseProduction: Decimal.fromInt(5),
        costMultiplier: 1.15,
        icon: '☀️',
      ),
      Generator(
        id: 'energy_gen_3',
        name: 'Fusion Reactor',
        description: 'Advanced fusion technology',
        baseCost: Decimal.fromInt(1000),
        baseProduction: Decimal.fromInt(25),
        costMultiplier: 1.15,
        icon: '⚛️',
      ),
      Generator(
        id: 'energy_gen_4',
        name: 'Quantum Generator',
        description: 'Quantum energy extraction',
        baseCost: Decimal.fromInt(10000),
        baseProduction: Decimal.fromInt(100),
        costMultiplier: 1.15,
        icon: '🔮',
      ),
    ];
  }

  /// Start game loop
  void _startGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateGameState();
    });
  }

  /// Update game state every tick
  void _updateGameState() {
    final earned = state.updateEnergy();

    // IMPORTANT: Must reassign state to trigger Riverpod update
    if (earned > Decimal.zero) {
      state = state.copyWith();

      // Update stats
      _stats?.updateMaxEnergy(state.energy);
      _stats?.updateMaxEnergyPerSecond(state.getEnergyPerSecond());

      // Trigger debounced save
      _saveManager?.saveDebounced(state);
    }
  }

  // ========== GENERATOR ACTIONS ==========

  /// Purchase generator
  void purchaseGenerator(String generatorId, {int amount = 1}) {
    final success = state.purchaseGenerator(generatorId, amount: amount);

    if (success) {
      state = state.copyWith();
      _stats?.incrementGeneratorsPurchased(count: amount);
      LoggerService.info('Purchased $amount x $generatorId');
    }
  }

  /// Get generator by ID
  Generator? getGenerator(String id) {
    return state.getGenerator(id);
  }

  // ========== MANUAL ACTIONS ==========

  /// Manual click to add energy
  void clickEnergy({Decimal? amount}) {
    final clickAmount = amount ?? Decimal.one;
    state.addEnergy(clickAmount);
    state = state.copyWith();
    _stats?.incrementClicks();
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
    );
  }

  /// Reset game (hard reset)
  Future<void> resetGame() async {
    if (_saveManager == null) return;

    await _saveManager!.saveService.clearAllData();
    state = _createInitialState();
    _stats = GameStats();
    _prestigeData = PrestigeData();

    LoggerService.info('Game reset completed');
  }

  // ========== GETTERS ==========

  GameStats? get stats => _stats;
  PrestigeData? get prestigeData => _prestigeData;
  Decimal get energy => state.energy;
  Decimal get energyPerSecond => state.getEnergyPerSecond();
  List<Generator> get generators => state.generators;
}

/// Provider for comprehensive game controller
final comprehensiveGameControllerProvider =
    NotifierProvider<ComprehensiveGameController, GameState>(
  ComprehensiveGameController.new,
);
