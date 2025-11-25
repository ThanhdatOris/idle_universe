import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/widgets/widgets.dart';
import 'package:idle_universe/features/home/presentation/logic/comprehensive_game_controller.dart';

/// AchievementsScreen - Display all achievements and their progress
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(comprehensiveGameControllerProvider.notifier);
    final gameState = ref.watch(comprehensiveGameControllerProvider);
    final achievementService = controller.achievementService;

    if (achievementService == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = achievementService.getStatistics();
    final achievements = achievementService.achievements;

    return CosmicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: 'Achievements',
          subtitle:
              '${stats['unlocked']}/${stats['total']} Unlocked (${stats['percentage']}%)',
        ),
        body: CustomScrollView(
          slivers: [
            // Statistics Card
            SliverToBoxAdapter(
              child: _buildStatisticsCard(context, stats),
            ),

            // Filter Tabs
            SliverToBoxAdapter(
              child: _buildFilterTabs(context),
            ),

            // Achievements List
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final achievement = achievements[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAchievementCard(
                        context,
                        achievement,
                        controller,
                        gameState,
                      ),
                    );
                  },
                  childCount: achievements.length,
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  /// Build statistics card
  Widget _buildStatisticsCard(
      BuildContext context, Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: Icons.emoji_events,
            label: 'Unlocked',
            value: '${stats['unlocked']}',
            color: Colors.amber,
          ),
          _buildStatItem(
            context,
            icon: Icons.lock_outline,
            label: 'Locked',
            value: '${stats['locked']}',
            color: Colors.grey,
          ),
          _buildStatItem(
            context,
            icon: Icons.percent,
            label: 'Progress',
            value: '${stats['percentage']}%',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
        ),
      ],
    );
  }

  /// Build filter tabs (placeholder for now)
  Widget _buildFilterTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(
            'All Achievements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Build achievement card
  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement,
    controller,
    gameState,
  ) {
    final progress = controller.achievementService?.getProgress(
          achievement.id,
          stats: controller.stats ?? GameStats(),
          gameState: gameState,
          prestigeData: controller.prestigeData,
        ) ??
        0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: achievement.isUnlocked
              ? [
                  Colors.amber.withValues(alpha: 0.2),
                  Colors.orange.withValues(alpha: 0.1),
                ]
              : [
                  Colors.grey.withValues(alpha: 0.1),
                  Colors.grey.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          CustomListItem(
            leadingWidget: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? Colors.amber.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: achievement.name,
            subtitle: achievement.description,
            trailing: achievement.isUnlocked
                ? const Icon(Icons.check_circle, color: Colors.amber)
                : Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ),
          if (!achievement.isUnlocked)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}
