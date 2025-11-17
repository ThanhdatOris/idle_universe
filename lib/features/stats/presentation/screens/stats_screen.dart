import 'package:flutter/material.dart';
import 'package:idle_universe/core/widgets/widgets.dart';

/// Stats Screen - Màn hình thống kê
/// 
/// Hiển thị:
/// - Total clicks, play time
/// - Max energy reached
/// - Generators purchased
/// - Achievements unlocked
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EnergyGridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          title: 'Statistics',
          subtitle: '📊 Game Progress',
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          _buildStatCategory(
            context,
            title: 'Game Progress',
            icon: Icons.trending_up,
            iconColor: Colors.blue,
            stats: [
              _StatItem('Total Play Time', '0h 0m', Icons.access_time),
              _StatItem('Total Clicks', '0', Icons.touch_app),
              _StatItem('Prestige Count', '0', Icons.auto_awesome),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCategory(
            context,
            title: 'Resources',
            icon: Icons.energy_savings_leaf,
            iconColor: Colors.amber,
            stats: [
              _StatItem('Max Energy', '0', Icons.bolt),
              _StatItem('Total Energy Earned', '0', Icons.battery_charging_full),
              _StatItem('Energy Per Second', '0/s', Icons.speed),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCategory(
            context,
            title: 'Buildings',
            icon: Icons.business,
            iconColor: Colors.green,
            stats: [
              _StatItem('Total Generators', '0', Icons.factory),
              _StatItem('Total Upgrades', '0', Icons.upgrade),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCategory(
            context,
            title: 'Achievements',
            icon: Icons.emoji_events,
            iconColor: Colors.orange,
            stats: [
              _StatItem('Unlocked', '0 / 0', Icons.lock_open),
              _StatItem('Completion', '0%', Icons.pie_chart),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildStatCategory(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_StatItem> stats,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Stats List
            ...stats.map((stat) => _buildStatRow(context, stat)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, _StatItem stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            stat.icon,
            size: 20,
            color: Colors.white60,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stat.label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade300,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;

  _StatItem(this.label, this.value, this.icon);
}
