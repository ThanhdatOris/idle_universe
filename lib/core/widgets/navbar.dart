import 'package:flutter/material.dart';
import 'package:idle_universe/core/config/routes/app_routes.dart';
import 'package:idle_universe/core/config/theme/app_colors.dart';

/// Navigation bar widget - Thanh điều hướng chính cho ứng dụng
/// Hiển thị các tab chính: Home, Prestige, Settings, Stats
class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkSecondary,
      unselectedItemColor: AppColors.darkTextSecondary,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppRoutes.getRouteTitle(AppRoutes.home),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.autorenew),
          label: AppRoutes.getRouteTitle(AppRoutes.prestige),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: AppRoutes.getRouteTitle(AppRoutes.settings),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: AppRoutes.getRouteTitle(AppRoutes.stats),
        ),
      ],
    );
  }
}