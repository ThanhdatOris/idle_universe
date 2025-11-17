import 'package:flutter/material.dart';
import 'package:idle_universe/core/widgets/widgets.dart';
import 'package:idle_universe/features/home/presentation/screens/home_screen.dart';
import 'package:idle_universe/features/prestige/presentation/screens/prestige_screen.dart';
import 'package:idle_universe/features/settings/presentation/screens/settings_screen.dart';
import 'package:idle_universe/features/stats/presentation/screens/stats_screen.dart';

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
    const PrestigeScreen(),
    const SettingsScreen(),
    const StatsScreen(),
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
