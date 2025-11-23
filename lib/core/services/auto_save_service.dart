import 'dart:async';

import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/services/logger_service.dart';
import 'package:idle_universe/core/services/save_service.dart';

/// AutoSaveService - Tự động lưu game định kỳ
///
/// Chức năng:
/// - Auto-save mỗi X giây
/// - Save khi app vào background
/// - Debouncing để tránh save quá nhiều
class AutoSaveService {
  final SaveService _saveService;
  Timer? _autoSaveTimer;
  Timer? _debounceTimer;

  /// Thời gian giữa các lần auto-save (mặc định: 30 giây)
  final Duration autoSaveInterval;

  /// Thời gian debounce (mặc định: 2 giây)
  final Duration debounceInterval;

  /// Callback khi save thành công
  final void Function()? onSaveSuccess;

  /// Callback khi save thất bại
  final void Function(String error)? onSaveError;

  bool _isEnabled = true;
  DateTime? _lastSaveTime;

  AutoSaveService({
    required SaveService saveService,
    this.autoSaveInterval = const Duration(seconds: 30),
    this.debounceInterval = const Duration(seconds: 2),
    this.onSaveSuccess,
    this.onSaveError,
  }) : _saveService = saveService;

  /// Start auto-save timer
  void start() {
    if (!_isEnabled) return;

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(autoSaveInterval, (timer) {
      _performAutoSave();
    });
  }

  /// Stop auto-save timer
  void stop() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
  }

  /// Enable/disable auto-save
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      start();
    } else {
      stop();
    }
  }

  /// Save immediately (bypasses debounce)
  Future<bool> saveNow(GameState gameState) async {
    _debounceTimer?.cancel();
    return await _saveGameState(gameState);
  }

  /// Save with debounce (tránh save quá nhiều khi có nhiều thay đổi liên tục)
  void saveDebounced(GameState gameState) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceInterval, () {
      _saveGameState(gameState);
    });
  }

  /// Perform auto-save (internal)
  void _performAutoSave() {
    // Note: Cần truyền gameState từ controller
    // Sẽ được gọi từ GameController
  }

  /// Save game state (internal)
  Future<bool> _saveGameState(GameState gameState) async {
    try {
      final success = await _saveService.saveGameState(gameState);

      if (success) {
        _lastSaveTime = DateTime.now();
        onSaveSuccess?.call();
      } else {
        onSaveError?.call('Failed to save game state');
      }

      return success;
    } catch (e) {
      onSaveError?.call(e.toString());
      return false;
    }
  }

  /// Get time since last save
  Duration? getTimeSinceLastSave() {
    if (_lastSaveTime == null) return null;
    return DateTime.now().difference(_lastSaveTime!);
  }

  /// Dispose resources
  void dispose() {
    stop();
  }
}

/// SaveManager - Quản lý tổng thể việc save/load
///
/// Kết hợp SaveService và AutoSaveService
class SaveManager {
  final SaveService saveService;
  final AutoSaveService autoSaveService;

  SaveManager({
    required this.saveService,
    required this.autoSaveService,
  });

  /// Initialize SaveManager
  static Future<SaveManager> initialize({
    Duration autoSaveInterval = const Duration(seconds: 30),
    void Function()? onSaveSuccess,
    void Function(String error)? onSaveError,
  }) async {
    final saveService = await SaveService.initialize();
    final autoSaveService = AutoSaveService(
      saveService: saveService,
      autoSaveInterval: autoSaveInterval,
      onSaveSuccess: onSaveSuccess,
      onSaveError: onSaveError,
    );

    return SaveManager(
      saveService: saveService,
      autoSaveService: autoSaveService,
    );
  }

  /// Save complete game data
  Future<bool> saveCompleteGameData({
    required GameState gameState,
    GameStats? stats,
    PrestigeData? prestigeData,
    List<Achievement>? achievements,
    List<Upgrade>? upgrades,
  }) async {
    try {
      // Save game state
      final stateSuccess = await saveService.saveGameState(gameState);
      if (!stateSuccess) return false;

      // Save optional data
      if (stats != null) {
        await saveService.saveStats(stats);
      }

      if (prestigeData != null) {
        await saveService.savePrestigeData(prestigeData);
      }

      if (achievements != null) {
        await saveService.saveAchievements(achievements);
      }

      if (upgrades != null) {
        await saveService.saveUpgrades(upgrades);
      }

      return true;
    } catch (e) {
      LoggerService.error(
          'Error saving complete game data', e, null, 'SaveManager');
      return false;
    }
  }

  /// Load complete game data
  Future<Map<String, dynamic>> loadCompleteGameData() async {
    return {
      'gameState': await saveService.loadGameState(),
      'stats': await saveService.loadStats(),
      'prestigeData': await saveService.loadPrestigeData(),
      'achievements': await saveService.loadAchievements(),
      'upgrades': await saveService.loadUpgrades(),
    };
  }

  /// Start auto-save
  void startAutoSave() {
    autoSaveService.start();
  }

  /// Stop auto-save
  void stopAutoSave() {
    autoSaveService.stop();
  }

  /// Save now
  Future<bool> saveNow(GameState gameState) {
    return autoSaveService.saveNow(gameState);
  }

  /// Save with debounce
  void saveDebounced(GameState gameState) {
    autoSaveService.saveDebounced(gameState);
  }

  /// Dispose
  void dispose() {
    autoSaveService.dispose();
  }
}
