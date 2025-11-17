import 'package:flutter/material.dart';
import 'package:idle_universe/core/widgets/widgets.dart';

/// Prestige Screen - Màn hình Prestige/Reset
/// 
/// Cho phép người chơi:
/// - Reset game để nhận prestige points
/// - Prestige points tăng production multiplier vĩnh viễn
/// - Xem preview rewards trước khi prestige
class PrestigeScreen extends StatelessWidget {
  const PrestigeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleGradientBackground(
      colors: const [
        Color(0xFF1A0A2E), // Deep purple
        Color(0xFF2D1B3D), // Purple
        Color(0xFF0F2027), // Dark teal
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          title: 'Prestige',
          subtitle: '✨ Reset & Upgrade',
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon/Animation
                Icon(
                  Icons.auto_awesome,
                  size: 100,
                  color: Colors.amber.shade300,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Prestige System',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade300,
                      ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Reset your progress to gain Prestige Points\n'
                  'and unlock powerful permanent bonuses!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 48),

                // Coming Soon Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade700,
                        Colors.amber.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text(
                    'COMING SOON',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
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
