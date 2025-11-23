import 'dart:convert';

import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/services/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SaveService - Quản lý lưu/tải game state
///
/// Chức năng:
/// - Auto-save định kỳ
/// - Manual save/load
/// - Export/Import save data
/// - Multiple save slots (optional)
class SaveService {
  static const String _saveKey = 'idle_universe_save';
  static const String _settingsKey = 'idle_universe_settings';
  static const String _lastSaveTimeKey = 'idle_universe_last_save_time';

  final SharedPreferences _prefs;

  SaveService(this._prefs);

  /// Initialize service - load SharedPreferences
  static Future<SaveService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return SaveService(prefs);
  }

  // ========== GAME STATE ==========

  /// Save complete game state
  Future<bool> saveGameState(GameState gameState) async {
    try {
      final json = gameState.toJson();
      final jsonString = jsonEncode(json);

      final success = await _prefs.setString(_saveKey, jsonString);

      if (success) {
        await _prefs.setString(
          _lastSaveTimeKey,
          DateTime.now().toIso8601String(),
        );
      }

      return success;
    } catch (e) {
      LoggerService.error('Error saving game state', e, null, 'SaveService');
      return false;
    }
  }

  /// Load game state
  Future<GameState?> loadGameState() async {
    try {
      final jsonString = _prefs.getString(_saveKey);

      if (jsonString == null) {
        return null; // No save found
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(json);
    } catch (e) {
      LoggerService.error('Error loading game state', e, null, 'SaveService');
      return null;
    }
  }

  /// Check if save exists
  bool hasSaveData() {
    return _prefs.containsKey(_saveKey);
  }

  /// Get last save time
  DateTime? getLastSaveTime() {
    final timeString = _prefs.getString(_lastSaveTimeKey);
    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  /// Delete save data
  Future<bool> deleteSaveData() async {
    try {
      await _prefs.remove(_saveKey);
      await _prefs.remove(_lastSaveTimeKey);
      return true;
    } catch (e) {
      LoggerService.error('Error deleting save data', e, null, 'SaveService');
      return false;
    }
  }

  // ========== SETTINGS ==========

  /// Save settings
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      return await _prefs.setString(_settingsKey, jsonString);
    } catch (e) {
      LoggerService.error('Error saving settings', e, null, 'SaveService');
      return false;
    }
  }

  /// Load settings
  Map<String, dynamic>? loadSettings() {
    try {
      final jsonString = _prefs.getString(_settingsKey);
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      LoggerService.error('Error loading settings', e, null, 'SaveService');
      return null;
    }
  }

  /// Save individual setting
  Future<bool> saveSetting(String key, dynamic value) async {
    try {
      if (value is bool) {
        return await _prefs.setBool('setting_$key', value);
      } else if (value is int) {
        return await _prefs.setInt('setting_$key', value);
      } else if (value is double) {
        return await _prefs.setDouble('setting_$key', value);
      } else if (value is String) {
        return await _prefs.setString('setting_$key', value);
      }
      return false;
    } catch (e) {
      LoggerService.error('Error saving setting $key', e, null, 'SaveService');
      return false;
    }
  }

  /// Load individual setting
  T? loadSetting<T>(String key, {T? defaultValue}) {
    try {
      final value = _prefs.get('setting_$key');
      if (value == null) return defaultValue;
      return value as T;
    } catch (e) {
      LoggerService.error('Error loading setting $key', e, null, 'SaveService');
      return defaultValue;
    }
  }

  // ========== EXPORT/IMPORT ==========

  /// Export save data as JSON string (for backup)
  Future<String?> exportSaveData() async {
    try {
      final gameState = await loadGameState();
      if (gameState == null) return null;

      final exportData = {
        'version': '1.0.0',
        'exportTime': DateTime.now().toIso8601String(),
        'gameState': gameState.toJson(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      LoggerService.error('Error exporting save data', e, null, 'SaveService');
      return null;
    }
  }

  /// Import save data from JSON string
  Future<bool> importSaveData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version (optional - for future compatibility)
      final version = data['version'] as String?;
      if (version == null) {
        LoggerService.warning(
            'Invalid save data: missing version', 'SaveService');
        return false;
      }

      // Extract game state
      final gameStateJson = data['gameState'] as Map<String, dynamic>?;
      if (gameStateJson == null) {
        LoggerService.warning(
            'Invalid save data: missing gameState', 'SaveService');
        return false;
      }

      // Parse and save
      final gameState = GameState.fromJson(gameStateJson);
      return await saveGameState(gameState);
    } catch (e) {
      LoggerService.error('Error importing save data', e, null, 'SaveService');
      return false;
    }
  }

  // ========== STATISTICS ==========

  /// Save game statistics
  Future<bool> saveStats(GameStats stats) async {
    try {
      final json = stats.toJson();
      final jsonString = jsonEncode(json);
      return await _prefs.setString('game_stats', jsonString);
    } catch (e) {
      LoggerService.error('Error saving stats', e, null, 'SaveService');
      return false;
    }
  }

  /// Load game statistics
  Future<GameStats?> loadStats() async {
    try {
      final jsonString = _prefs.getString('game_stats');
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameStats.fromJson(json);
    } catch (e) {
      LoggerService.error('Error loading stats', e, null, 'SaveService');
      return null;
    }
  }

  // ========== PRESTIGE DATA ==========

  /// Save prestige data
  Future<bool> savePrestigeData(PrestigeData prestigeData) async {
    try {
      final json = prestigeData.toJson();
      final jsonString = jsonEncode(json);
      return await _prefs.setString('prestige_data', jsonString);
    } catch (e) {
      LoggerService.error('Error saving prestige data', e, null, 'SaveService');
      return false;
    }
  }

  /// Load prestige data
  Future<PrestigeData?> loadPrestigeData() async {
    try {
      final jsonString = _prefs.getString('prestige_data');
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PrestigeData.fromJson(json);
    } catch (e) {
      LoggerService.error(
          'Error loading prestige data', e, null, 'SaveService');
      return null;
    }
  }

  // ========== ACHIEVEMENTS ==========

  /// Save achievements
  Future<bool> saveAchievements(List<Achievement> achievements) async {
    try {
      final jsonList = achievements.map((a) => a.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs.setString('achievements', jsonString);
    } catch (e) {
      LoggerService.error('Error saving achievements', e, null, 'SaveService');
      return false;
    }
  }

  /// Load achievements
  Future<List<Achievement>?> loadAchievements() async {
    try {
      final jsonString = _prefs.getString('achievements');
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Error loading achievements', e, null, 'SaveService');
      return null;
    }
  }

  // ========== UPGRADES ==========

  /// Save upgrades
  Future<bool> saveUpgrades(List<Upgrade> upgrades) async {
    try {
      final jsonList = upgrades.map((u) => u.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs.setString('upgrades', jsonString);
    } catch (e) {
      LoggerService.error('Error saving upgrades', e, null, 'SaveService');
      return false;
    }
  }

  /// Load upgrades
  Future<List<Upgrade>?> loadUpgrades() async {
    try {
      final jsonString = _prefs.getString('upgrades');
      if (jsonString == null) return null;

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => Upgrade.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Error loading upgrades', e, null, 'SaveService');
      return null;
    }
  }

  // ========== UTILITY ==========

  /// Clear all data (hard reset)
  Future<bool> clearAllData() async {
    try {
      await _prefs.clear();
      return true;
    } catch (e) {
      LoggerService.error('Error clearing all data', e, null, 'SaveService');
      return false;
    }
  }

  /// Get save file size (approximate)
  int getSaveDataSize() {
    final jsonString = _prefs.getString(_saveKey);
    if (jsonString == null) return 0;
    return jsonString.length;
  }
}
