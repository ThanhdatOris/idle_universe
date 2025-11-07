import 'package:flutter/material.dart';
import 'package:idle_universe/core/widgets/navbar.dart';
import 'package:idle_universe/features/home/presentation/screens/home_screen.dart';
import 'package:idle_universe/features/settings/presentation/screens/setting_screen.dart';

/// MainScreen - Screen chính với bottom navigation
/// 
/// Quản lý navigation giữa:
/// - Home (game chính)
/// - Prestige
/// - Settings
/// - Stats
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const PrestigeScreen(), // TODO: Tạo PrestigeScreen
    const SettingScreen(),
    const StatsScreen(), // TODO: Tạo StatsScreen
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// === Placeholder Screens ===

/// Prestige screen (placeholder)
class PrestigeScreen extends StatelessWidget {
  const PrestigeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestige'),
      ),
      body: const Center(
        child: Text('Prestige Screen\n(Coming Soon)'),
      ),
    );
  }
}

/// Stats screen (placeholder)
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: const Center(
        child: Text('Stats Screen\n(Coming Soon)'),
      ),
    );
  }
}
