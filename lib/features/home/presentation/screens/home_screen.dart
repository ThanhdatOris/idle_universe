import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/utils/utils.dart';
import 'package:idle_universe/core/widgets/widgets.dart';
import 'package:idle_universe/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:idle_universe/features/home/presentation/flame/universe_game.dart';
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
  bool _menuExpanded = false;
  int _tapAnimationKey = 0;
  BuyQuantity _buyQuantity = BuyQuantity.one;

  // Game instance reference
  late final UniverseGame _game;

  @override
  void initState() {
    super.initState();
    _game = UniverseGame(onCoreTap: _onEnergyTap);

    // Setup achievement callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(comprehensiveGameControllerProvider.notifier);
      controller.setAchievementCallback(_showAchievementNotification);

      // Initialize generator visuals
      final gameState = ref.read(comprehensiveGameControllerProvider);
      final counts = <String, int>{};
      for (final gen in gameState.generators) {
        counts[gen.id] = gen.owned;
      }
      _game.updateGenerators(counts);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _showAchievementNotification(Achievement achievement) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Achievement Unlocked!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(achievement.name),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () => _navigateToAchievements(context),
        ),
      ),
    );
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
    final gameState = ref.read(comprehensiveGameControllerProvider);

    int amount = _buyQuantity.value;

    // Calculate max affordable if MAX option selected
    if (_buyQuantity.isMax) {
      final generator = gameState.getGenerator(generatorId);
      if (generator != null) {
        final maxInfo = generator.calculateMaxBuy(gameState.energy);
        amount = maxInfo['amount'] as int;
      }
    }

    if (amount > 0) {
      final purchased =
          controller.purchaseGenerator(generatorId, amount: amount);

      if (purchased > 0) {
        // Trigger animation
        setState(() => _tapAnimationKey++);

        // Trigger Flame effect (center of screen for now)
        // In a real app we'd get the tap position
        _game.spawnClickEffect(Vector2(_game.size.x / 2, _game.size.y / 2));

        // Update generator visuals
        final counts = <String, int>{};
        for (final gen in gameState.generators) {
          counts[gen.id] = gen.owned;
        }
        _game.updateGenerators(counts);
      }
    }
  }

  void _onEnergyTap() {
    final controller = ref.read(comprehensiveGameControllerProvider.notifier);
    controller.clickEnergy();
    setState(() => _tapAnimationKey++);

    // Trigger Flame effect
    // Random position around center
    final center = Vector2(_game.size.x / 2, _game.size.y / 2);
    final offset = Vector2(
      (DateTime.now().millisecond % 100 - 50).toDouble(),
      (DateTime.now().microsecond % 100 - 50).toDouble(),
    );
    _game.spawnClickEffect(center + offset);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(comprehensiveGameControllerProvider);
    final controller = ref.read(comprehensiveGameControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Flame Game Background
          Positioned.fill(
            child: GameWidget(
              game: _game,
            ),
          ),

          // Main UI Overlay
          SafeArea(
            child: Column(
              children: [
                // Resources Bar at top
                ResourcesBar(
                  energy: gameState.energy,
                  energyPerSecond: gameState.getEnergyPerSecond(),
                  clickPower:
                      controller.upgradeService?.getClickPowerMultiplier(),
                ),

                // Buy Quantity Selector
                _buildBuyQuantitySelector(),

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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
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

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildGeneratorCard(
                                  context,
                                  generator,
                                  index,
                                  gameState,
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
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(context, controller),
    );
  }

  /// Build generator card with hold-to-buy functionality
  Widget _buildGeneratorCard(
    BuildContext context,
    Generator generator,
    int index,
    gameState,
  ) {
    int buyAmount = 1;
    Decimal displayCost = generator.getCurrentCost();
    bool canAfford = false;

    // Calculate Buy Amount & Cost
    if (_buyQuantity.isMax) {
      final maxInfo = generator.calculateMaxBuy(gameState.energy);
      int maxAmount = maxInfo['amount'] as int;
      if (maxAmount > 0) {
        buyAmount = maxAmount;
        displayCost = maxInfo['totalCost'] as Decimal;
        canAfford = true;
      } else {
        // Can't afford even 1, show cost of 1
        buyAmount = 1;
        displayCost = generator.getCurrentCost();
        canAfford = false;
      }
    } else {
      buyAmount = _buyQuantity.value;
      displayCost = generator.getCostForAmount(buyAmount);
      canAfford = gameState.energy >= displayCost;
    }

    // Calculate predicted impact (production increase)
    // We calculate the difference between future production (after purchase) and current production
    final currentProduction = generator.getTotalProduction();

    // Calculate future production
    final futureOwned = generator.owned + buyAmount;
    double futureMultiplier = 1.0;
    for (final milestone in generator.milestones) {
      if (futureOwned >= milestone.threshold) {
        futureMultiplier *= milestone.multiplier;
      }
    }

    final futureBaseTotal =
        generator.baseProduction * Decimal.fromInt(futureOwned);
    final futureTotalProduction =
        futureBaseTotal * Decimal.parse(futureMultiplier.toString());

    final productionIncrease = futureTotalProduction - currentProduction;

    return ItemCard(
      id: generator.id,
      name: generator.name,
      description: generator.description,
      icon: generator.icon,
      cost: displayCost,
      canAfford: canAfford,
      owned: generator.owned,
      productionText: generator.owned > 0
          ? '${NumberFormatter.format(generator.getTotalProduction())}/s'
          : '${NumberFormatter.format(generator.baseProduction)}/s each',
      milestoneInfo: _getMilestoneInfo(generator),
      predictedImpactText: '+${NumberFormatter.format(productionIncrease)}/s',
      buyAmount: buyAmount,
      onPurchase: () {
        // Single tap buy
        _buyGenerator(generator.id);
      },
      onLongPress: canAfford ? () => _startHoldBuying(generator.id) : null,
      onHoldRelease: () => _stopHoldBuying(),
      accentColor: _getGeneratorColor(index),
    );
  }

  /// Get milestone info text for generator
  String? _getMilestoneInfo(Generator generator) {
    final nextMilestone = generator.getNextMilestone();
    if (nextMilestone == null) {
      return null; // All milestones unlocked
    }

    final remaining = nextMilestone.threshold - generator.owned;
    return 'Next: ${nextMilestone.threshold} owned → ${nextMilestone.multiplier.toStringAsFixed(1)}x ($remaining more)';
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
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
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
                  size: 32,
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'TAP FOR ENERGY',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                                letterSpacing: 2,
                              ),
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

  /// Build buy quantity selector
  Widget _buildBuyQuantitySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_cart,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Buy:',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: BuyQuantity.values.map((quantity) {
                  final isSelected = _buyQuantity == quantity;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _buyQuantity = quantity;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.withValues(alpha: 0.5),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          quantity.label,
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.grey[400],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
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
