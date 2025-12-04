import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/core/utils/utils.dart';
import 'package:idle_universe/core/widgets/widgets.dart';
import 'package:idle_universe/features/home/presentation/logic/comprehensive_game_controller.dart';

/// Stats Screen - Màn hình thống kê
///
/// Hiển thị:
/// - Total clicks, play time
/// - Max energy reached
/// - Generators purchased
/// - Achievements unlocked
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(comprehensiveGameControllerProvider);
    final controller = ref.read(comprehensiveGameControllerProvider.notifier);
    final stats = controller.stats;
    final achievementService = controller.achievementService;

    // Format play time
    final playTimeSeconds = stats?.totalPlayTimeSeconds ?? 0;
    final playTime = Duration(seconds: playTimeSeconds);
    String playTimeStr = '';
    if (playTime.inHours > 0) {
      playTimeStr = '${playTime.inHours}h ${playTime.inMinutes % 60}m';
    } else {
      playTimeStr = '${playTime.inMinutes}m ${playTime.inSeconds % 60}s';
    }

    // Achievement progress
    final unlockedAchievements =
        achievementService?.unlockedAchievements.length ?? 0;
    final totalAchievements = achievementService?.achievements.length ?? 0;
    final achievementPercent = totalAchievements > 0
        ? (unlockedAchievements / totalAchievements * 100).toStringAsFixed(1)
        : '0.0';

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
                _StatItem('Total Play Time', playTimeStr, Icons.access_time),
                _StatItem(
                    'Total Clicks',
                    NumberFormatter.format(
                        Decimal.fromInt(stats?.totalClicks ?? 0)),
                    Icons.touch_app),
                _StatItem(
                    'Prestige Count',
                    NumberFormatter.format(
                        Decimal.fromInt(stats?.totalPrestiges ?? 0)),
                    Icons.auto_awesome),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCategory(
              context,
              title: 'Resources',
              icon: Icons.energy_savings_leaf,
              iconColor: Colors.amber,
              stats: [
                _StatItem(
                    'Max Energy',
                    NumberFormatter.format(stats?.maxEnergy ?? Decimal.zero),
                    Icons.bolt),
                _StatItem(
                    'Total Energy Earned',
                    NumberFormatter.format(gameState.totalEnergyEarned),
                    Icons.battery_charging_full),
                _StatItem(
                    'Energy Per Second',
                    '${NumberFormatter.format(controller.energyPerSecond)}/s',
                    Icons.speed),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCategory(
              context,
              title: 'Buildings',
              icon: Icons.business,
              iconColor: Colors.green,
              stats: [
                _StatItem(
                    'Total Generators',
                    NumberFormatter.format(
                        Decimal.fromInt(stats?.totalGeneratorsPurchased ?? 0)),
                    Icons.factory),
                _StatItem(
                    'Total Upgrades',
                    NumberFormatter.format(
                        Decimal.fromInt(stats?.totalUpgradesPurchased ?? 0)),
                    Icons.upgrade),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCategory(
              context,
              title: 'Achievements',
              icon: Icons.emoji_events,
              iconColor: Colors.orange,
              stats: [
                _StatItem(
                    'Unlocked',
                    '$unlockedAchievements / $totalAchievements',
                    Icons.lock_open),
                _StatItem(
                    'Completion', '$achievementPercent%', Icons.pie_chart),
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
