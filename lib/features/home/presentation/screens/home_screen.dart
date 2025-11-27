import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/core/widgets/widgets.dart';
import 'package:idle_universe/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:idle_universe/features/home/presentation/logic/comprehensive_game_controller.dart';
import 'package:idle_universe/features/upgrades/presentation/screens/upgrades_screen.dart';

/// HomeScreen - Main game screen with generators
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _holdTimer;
    super.dispose();
  }

  void _startHoldBuying(String generatorId) {
    // Buy immediately on press
    _buyGenerator(generatorId);

    // Then buy every 100ms while holding
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _buyGenerator(generatorId);
    });
  }

  void _stopHoldBuying() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _buyGenerator(String generatorId) {
    final controller = ref.read(comprehensiveGameControllerProvider.notifier);
    final purchased = controller.purchaseGenerator(generatorId);

    if (purchased > 0) {
      // Trigger animation
      setState(() => _tapAnimationKey++);
    }
  }

  void _onEnergyTap() {
    final controller = ref.read(comprehensiveGameControllerProvider.notifier);
    controller.clickEnergy();
    setState(() => _tapAnimationKey++);
  }

  @override
  Widget build(BuildContext context) {
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
                    child: _buildEnergyDisplay(context, gameState),
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
                          const Spacer(),
                          Text(
                            'Hold to buy continuously',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
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
                            child: _buildGeneratorCard(
                              context,
                              generator,
                              cost,
                              canAfford,
                              index,
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

  /// Build generator card with hold-to-buy functionality
  Widget _buildGeneratorCard(
    BuildContext context,
    generator,
    cost,
    bool canAfford,
    int index,
  ) {
    return ItemCard(
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
        // Single tap buy
        _buyGenerator(generator.id);
      },
      onLongPress: canAfford ? () => _startHoldBuying(generator.id) : null,
      onHoldRelease: () => _stopHoldBuying(),
      accentColor: _getGeneratorColor(index),
    );
  }

  /// Build energy display section - large tappable area
  Widget _buildEnergyDisplay(
    BuildContext context,
    gameState,
  ) {
    return GestureDetector(
      onTap: _onEnergyTap,
      child: AnimatedContainer(
        key: ValueKey(_tapAnimationKey),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withValues(alpha: 0.4),
              Colors.blue.withValues(alpha: 0.3),
              Colors.cyan.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.6),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Animated energy orb
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.3),
                        Colors.amber.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Middle layer
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.6),
                        Colors.orange.withValues(alpha: 0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Icon
                const Icon(
                  Icons.bolt,
                  size: 64,
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tap instruction
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.3),
                    Colors.orange.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.touch_app,
                    color: Colors.amber,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TAP FOR ENERGY',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          letterSpacing: 2,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    icon: Icons.speed,
                    label: 'Per Second',
                    value:
                        '${gameState.getEnergyPerSecond().toStringAsFixed(1)}',
                    color: Colors.green,
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.2),
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
            ),
          ],
        ),
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

  /// Build floating action buttons with expandable menu
  Widget _buildFloatingActions(BuildContext context, controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu items (shown when expanded)
        if (_menuExpanded) ...[
          _buildMenuButton(
            context,
            icon: Icons.emoji_events,
            label: 'Achievements',
            color: Colors.amber,
            onTap: () => _navigateToAchievements(context),
          ),
          const SizedBox(height: 12),
          _buildMenuButton(
            context,
            icon: Icons.upgrade,
            label: 'Upgrades',
            color: Colors.purple,
            onTap: () => _navigateToUpgrades(context),
          ),
          const SizedBox(height: 12),
          _buildMenuButton(
            context,
            icon: Icons.save,
            label: 'Save',
            color: Colors.green,
            onTap: () => _saveGame(context, controller),
          ),
          const SizedBox(height: 12),
          if (controller.canPrestige())
            _buildMenuButton(
              context,
              icon: Icons.auto_awesome,
              label: 'Prestige',
              color: Colors.purple,
              onTap: () => _showPrestigeDialog(context, controller),
            ),
          if (controller.canPrestige()) const SizedBox(height: 12),
        ],

        // Main menu button
        FloatingActionButton(
          heroTag: 'menu',
          onPressed: () {
            setState(() {
              _menuExpanded = !_menuExpanded;
            });
          },
          backgroundColor: _menuExpanded ? Colors.red : Colors.blue,
          child: AnimatedRotation(
            turns: _menuExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(_menuExpanded ? Icons.close : Icons.menu),
          ),
        ),
      ],
    );
  }

  /// Build individual menu button
  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedScale(
      scale: _menuExpanded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: label,
            mini: true,
            onPressed: onTap,
            backgroundColor: color,
            child: Icon(icon),
          ),
        ],
      ),
    );
  }

  /// Navigate to Achievements screen
  void _navigateToAchievements(BuildContext context) {
    setState(() => _menuExpanded = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AchievementsScreen(),
      ),
    );
  }

  /// Navigate to Upgrades screen
  void _navigateToUpgrades(BuildContext context) {
    setState(() => _menuExpanded = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpgradesScreen(),
      ),
    );
  }

  /// Save game
  Future<void> _saveGame(BuildContext context, controller) async {
    setState(() => _menuExpanded = false);
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
