/// App routes - Định nghĩa routes cho Navigator
/// Sử dụng named routes để dễ quản lý navigation
class AppRoutes {
  // === MAIN ROUTES ===
  static const String home = '/'; // Home screen (game chính)
  static const String prestige = '/prestige'; // Prestige screen
  static const String settings = '/settings'; // Settings screen
  static const String stats = '/stats'; // Statistics screen

  // === FEATURE ROUTES (future) ===
  static const String achievements = '/achievements'; // Achievements
  static const String leaderboard = '/leaderboard'; // Leaderboard
  static const String shop = '/shop'; // In-app shop (nếu có)
  
  // === UTILITY ROUTES ===
  static const String about = '/about'; // About screen
  static const String tutorial = '/tutorial'; // Tutorial/onboarding
  static const String changelog = '/changelog'; // Changelog screen

  // === Helper: Get route title ===
  static String getRouteTitle(String route) {
    switch (route) {
      case home:
        return 'Home';
      case prestige:
        return 'Prestige';
      case settings:
        return 'Settings';
      case stats:
        return 'Statistics';
      case achievements:
        return 'Achievements';
      case leaderboard:
        return 'Leaderboard';
      case shop:
        return 'Shop';
      case about:
        return 'About';
      case tutorial:
        return 'Tutorial';
      case changelog:
        return 'Changelog';
      default:
        return 'Unknown';
    }
  }

  // === Helper: Check if route exists ===
  static bool isValidRoute(String route) {
    return [
      home,
      prestige,
      settings,
      stats,
      achievements,
      leaderboard,
      shop,
      about,
      tutorial,
      changelog,
    ].contains(route);
  }
}
