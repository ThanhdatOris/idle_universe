import 'package:flutter/material.dart';
import 'package:idle_universe/core/config/theme/app_colors.dart';

/// Navigation bar widget - Thanh điều hướng với hiệu ứng đẹp
/// Hiển thị các tab chính: Home, Prestige, Settings, Stats
class NavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int? _tappedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkSurface,
            AppColors.darkBackground,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSecondary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: SizedBox(
          height: 65,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.auto_awesome_rounded,
                  label: 'Prestige',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.bar_chart_rounded,
                  label: 'Stats',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.currentIndex == index;
    final isTapped = _tappedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _tappedIndex = index);
        },
        onTapUp: (_) {
          setState(() => _tappedIndex = null);
          widget.onTap(index);
        },
        onTapCancel: () {
          setState(() => _tappedIndex = null);
        },
        child: AnimatedScale(
          scale: isTapped ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.darkPrimary.withValues(alpha: 0.3),
                        AppColors.darkSecondary.withValues(alpha: 0.3),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppColors.darkSecondary.withValues(alpha: 0.5),
                      width: 1.5,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.darkSecondary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Icon(
                    icon,
                    size: isSelected ? 26 : 24,
                    color: isSelected
                        ? AppColors.darkSecondary
                        : AppColors.darkTextSecondary,
                    shadows: isSelected
                        ? [
                            Shadow(
                              color: AppColors.darkSecondary,
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSelected ? 11 : 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.darkSecondary
                          : AppColors.darkTextSecondary,
                      letterSpacing: 0.3,
                      shadows: isSelected
                          ? [
                              Shadow(
                                color: AppColors.darkSecondary.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}