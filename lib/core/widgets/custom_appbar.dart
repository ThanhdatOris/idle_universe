import 'package:flutter/material.dart';
import 'package:idle_universe/core/config/theme/app_colors.dart';

/// CustomAppBar - AppBar đẹp cho Idle Universe
/// 
/// Features:
/// - Gradient background (space theme)
/// - Glowing effect
/// - Custom typography
/// - Subtitle support (optional)
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A3E), // Darker purple
            const Color(0xFF0D1F2D), // Dark blue
            const Color(0xFF1A1A3E), // Darker purple
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkSecondary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppBar(
        title: _buildTitle(context),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        leading: leading,
        actions: actions,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (subtitle == null) {
      return Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black87,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
            Shadow(
              color: Color(0xFF00E5FF),
              blurRadius: 20,
              offset: Offset(0, 0),
            ),
          ],
        ),
      );
    }

    // With subtitle
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black87,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
              Shadow(
                color: Color(0xFF00E5FF),
                blurRadius: 20,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle!,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
            color: Color(0xFFB0BEC5), // Light gray-blue
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// GlowingAppBar - AppBar với hiệu ứng phát sáng mạnh hơn
/// Dùng cho các màn hình đặc biệt (Prestige, Boss...)
class GlowingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color glowColor;
  final List<Widget>? actions;
  final Widget? leading;

  const GlowingAppBar({
    super.key,
    required this.title,
    this.glowColor = const Color(0xFF00E5FF),
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A0A2E), // Very dark purple
            glowColor.withValues(alpha: 0.15),
            const Color(0xFF0A0E27), // Deep space
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.2),
            blurRadius: 35,
            spreadRadius: 5,
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.white,
                  glowColor.withValues(alpha: 0.9),
                  Colors.white,
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            shadows: [
              const Shadow(
                color: Colors.black87,
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
              Shadow(
                color: glowColor,
                blurRadius: 15,
              ),
              Shadow(
                color: glowColor.withValues(alpha: 0.6),
                blurRadius: 30,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: leading,
        actions: actions,
      ),
    );
  }
}

/// SimpleAppBar - AppBar đơn giản, clean cho Settings/Stats
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const SimpleAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black54,
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF1A1A3E),
      elevation: 4,
      leading: leading,
      actions: actions,
      shadowColor: Colors.black.withValues(alpha: 0.6),
    );
  }
}
