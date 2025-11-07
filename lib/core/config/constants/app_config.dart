/// App configuration - Cấu hình toàn app
/// Chứa version, feature flags, API endpoints (nếu có)
class AppConfig {
  // === APP INFO ===
  static const String appName = 'Idle Universe Builder';
  static const String appVersion = '0.1.0'; // Alpha version
  static const String buildNumber = '1';

  // === FEATURES FLAGS (bật/tắt tính năng khi dev) ===
  static const bool enablePrestige = true; // Prestige system
  static const bool enableOfflineProgress = true; // Offline progression
  static const bool enableAchievements = false; // Achievements (chưa làm)
  static const bool enableLeaderboard = false; // Leaderboard (chưa làm)
  static const bool enableSound = true; // Sound effects
  static const bool enableMusic = false; // Background music (chưa có)

  // === DEBUG ===
  static const bool debugMode = true; // Hiển thị debug info
  static const bool showFPS = false; // Hiển thị FPS counter
  static const bool enableDevCheats = true; // Cheat codes (cho debug)

  // === SAVE/LOAD ===
  static const bool autoSaveEnabled = true;
  static const bool cloudSaveEnabled = false; // Cloud save (chưa làm)

  // === ANALYTICS (future) ===
  static const bool enableAnalytics = false;
  static const String analyticsKey = ''; // Firebase Analytics key

  // === THEME ===
  static const bool defaultToDarkTheme = true; // Default theme
  static const bool allowThemeSwitch = true; // Cho phép đổi theme

  // === GAMEPLAY TWEAKS (cho testing) ===
  static const double timeMultiplier = 1.0; // 1.0 = normal, 2.0 = 2x speed (debug)
  static const bool skipTutorial = false; // Bỏ qua tutorial

  // === CONTACT/LINKS ===
  static const String supportEmail = 'support@idleuniverse.com';
  static const String githubRepo = 'https://github.com/ThanhdatOris/idle_universe';
  static const String discordLink = ''; // Discord server (nếu có)

  // === Helper: Check if feature enabled ===
  static bool isFeatureEnabled(String featureName) {
    switch (featureName) {
      case 'prestige':
        return enablePrestige;
      case 'offline':
        return enableOfflineProgress;
      case 'achievements':
        return enableAchievements;
      case 'leaderboard':
        return enableLeaderboard;
      case 'sound':
        return enableSound;
      case 'music':
        return enableMusic;
      default:
        return false;
    }
  }
}
