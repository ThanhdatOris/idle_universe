import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/core/widgets/widgets.dart';
import 'package:idle_universe/features/home/presentation/logic/comprehensive_game_controller.dart';

/// HomeScreen - Main game screen with generators
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(comprehensiveGameControllerProvider);
    final controller = ref.read(comprehensiveGameControllerProvider.notifier);

    return CosmicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          title: 'Idle Universe',
          subtitle: '🌌 Build Your Universe',
        ),
        body: Column(
          children: [
            // Resources Bar at top
            ResourcesBar(
              energy: gameState.energy,
              energyPerSecond: gameState.getEnergyPerSecond(),
            ),

            // Main content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Energy Display Section
                  SliverToBoxAdapter(
                    child: _buildEnergyDisplay(context, gameState, controller),
                  ),

                  // Generators Section Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.factory, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Generators',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade300,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Generators List
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final generator = gameState.generators[index];
                          final cost = generator.getCurrentCost();
                          final canAfford = gameState.canAfford(cost);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ItemCard(
                              id: generator.id,
                              name: generator.name,
                              description: generator.description,
                              icon: generator.icon,
                              cost: cost,
                              canAfford: canAfford,
                              owned: generator.owned,
                              productionText: generator.owned > 0
                                  ? '${generator.getTotalProduction().toStringAsFixed(1)}/s'
                                  : '${generator.baseProduction.toStringAsFixed(1)}/s each',
                              onPurchase: () {
                                controller.purchaseGenerator(generator.id);
                              },
                              accentColor: _getGeneratorColor(index),
                            ),
                          );
                        },
                        childCount: gameState.generators.length,
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
          ],
        ),
        floatingActionButton: _buildFloatingActions(context, controller),
      ),
    );
  }

  /// Build energy display section
  Widget _buildEnergyDisplay(
    BuildContext context,
    gameState,
    controller,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.3),
            Colors.blue.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Energy icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.5),
                  Colors.amber.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: const Icon(
              Icons.bolt,
              size: 48,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),

          // Click to earn button
          ElevatedButton(
            onPressed: () => controller.clickEnergy(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app),
                const SizedBox(width: 8),
                Text(
                  'Tap for Energy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.speed,
                label: 'Per Second',
                value: '${gameState.getEnergyPerSecond().toStringAsFixed(1)}',
                color: Colors.green,
              ),
              _buildStatItem(
                context,
                icon: Icons.trending_up,
                label: 'Total Earned',
                value: '${gameState.totalEnergyEarned.toStringAsFixed(0)}',
                color: Colors.blue,
              ),
            ],
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  /// Build floating action buttons
  Widget _buildFloatingActions(BuildContext context, controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Save button
        FloatingActionButton(
          heroTag: 'save',
          onPressed: () async {
            final success = await controller.saveGame();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Game saved!' : 'Failed to save'),
                  backgroundColor: success ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.save),
        ),
        const SizedBox(height: 12),

        // Prestige button (if available)
        if (controller.canPrestige())
          FloatingActionButton.extended(
            heroTag: 'prestige',
            onPressed: () {
              _showPrestigeDialog(context, controller);
            },
            backgroundColor: Colors.purple,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Prestige'),
          ),
      ],
    );
  }

  /// Show prestige confirmation dialog
  void _showPrestigeDialog(BuildContext context, controller) {
    final gain = controller.calculatePrestigeGain();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Text('Prestige'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset your progress to gain Prestige Points?\n',
              style: TextStyle(fontSize: 16),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '+${gain.toStringAsFixed(2)} Prestige Points',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This will reset all generators and energy, but you\'ll gain permanent bonuses!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.performPrestige();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prestige completed! 🎉'),
                  backgroundColor: Colors.purple,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Prestige Now'),
          ),
        ],
      ),
    );
  }

  /// Get color for generator based on index
  Color _getGeneratorColor(int index) {
    final colors = [
      Colors.amber,
      Colors.orange,
      Colors.purple,
      Colors.blue,
      Colors.cyan,
      Colors.green,
      Colors.pink,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
