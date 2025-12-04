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
  Timer? _particleTimer; // Timer for visual effects
  bool _menuExpanded = false;
  bool _uiVisible = true; // Toggle for hiding UI
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

      // Check for offline rewards
      _checkOfflineRewards(controller);
    });

    // Start particle effect timer
    _particleTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        final gameState = ref.read(comprehensiveGameControllerProvider);
        if (gameState.getEnergyPerSecond() > Decimal.zero) {
          _game.spawnResourceCollection();
        }
      }
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _particleTimer?.cancel();
    super.dispose();
  }

  void _checkOfflineRewards(ComprehensiveGameController controller) {
    final rewardData = controller.offlineRewardData;
    if (rewardData != null) {
      final earned = rewardData['earned'] as Decimal;
      final time = rewardData['offlineTime'] as Duration;

      // Format duration
      String timeString = '';
      if (time.inHours > 0) {
        timeString = '${time.inHours}h ${time.inMinutes % 60}m';
      } else if (time.inMinutes > 0) {
        timeString = '${time.inMinutes}m ${time.inSeconds % 60}s';
      } else {
        timeString = '${time.inSeconds}s';
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(
            children: [
              Icon(Icons.bedtime, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Welcome Back!', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You were away for $timeString.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your generators produced:',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      '+${NumberFormatter.format(earned)} Energy',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                controller.markOfflineRewardShown();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Collect'),
            ),
          ],
        ),
      );
    }
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
            child: GestureDetector(
              onTap: () {
                if (!_uiVisible) {
                  setState(() => _uiVisible = true);
                }
              },
              child: GameWidget(
                game: _game,
              ),
            ),
          ),

          // Main UI Overlay
          AnimatedOpacity(
            opacity: _uiVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: IgnorePointer(
              ignoring: !_uiVisible,
              child: SafeArea(
                child: Column(
                  children: [
                    // Resources Bar at top
                    ResourcesBar(
                      energy: gameState.energy,
                      energyPerSecond: gameState.getEnergyPerSecond(),
                      clickPower:
                          controller.upgradeService?.getClickPowerMultiplier(),
                    ),

                    // Visibility Toggle (Small icon top right)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.visibility_off,
                              color: Colors.white54),
                          onPressed: () => setState(() => _uiVisible = false),
                          tooltip: 'Hide UI',
                        ),
                      ),
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
                                        context, generator, index, gameState),
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
            ),
          ),
        ],
      ),
      floatingActionButton:
          _uiVisible ? _buildFloatingActions(context, controller) : null,
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
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: BuyQuantity.values.map((quantity) {
                final isSelected = _buyQuantity == quantity;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _buyQuantity = quantity;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      quantity.label,
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action buttons (Menu)
  Widget _buildFloatingActions(
      BuildContext context, ComprehensiveGameController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_menuExpanded) ...[
          _buildMenuButton(
            icon: Icons.emoji_events,
            label: 'Achievements',
            onPressed: () => _navigateToAchievements(context),
          ),
          const SizedBox(height: 12),
          _buildMenuButton(
            icon: Icons.upgrade,
            label: 'Upgrades',
            onPressed: () => _navigateToUpgrades(context),
          ),
          const SizedBox(height: 12),
          _buildMenuButton(
            icon: Icons.save,
            label: 'Save Game',
            onPressed: () => _saveGame(context, controller),
          ),
          const SizedBox(height: 12),
          _buildMenuButton(
            icon: Icons.restart_alt,
            label: 'Prestige',
            color: Colors.purpleAccent,
            onPressed: () => _showPrestigeDialog(context, controller),
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _menuExpanded = !_menuExpanded;
            });
          },
          backgroundColor: _menuExpanded ? Colors.red : Colors.blue,
          child: Icon(_menuExpanded ? Icons.close : Icons.menu),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.blue,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon),
        ),
      ],
    );
  }

  void _navigateToAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AchievementsScreen()),
    );
  }

  void _navigateToUpgrades(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpgradesScreen()),
    );
  }

  Future<void> _saveGame(
      BuildContext context, ComprehensiveGameController controller) async {
    await controller.saveGame();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game Saved!')),
      );
    }
  }

  void _showPrestigeDialog(
      BuildContext context, ComprehensiveGameController controller) {
    final gain = controller.calculatePrestigeGain();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Text('Prestige', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset your progress to gain Prestige Points?\n',
              style: TextStyle(fontSize: 16, color: Colors.white70),
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
                    '+${NumberFormatter.format(gain)} Prestige Points',
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
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog first

              // Trigger animation then prestige
              _game.triggerPrestige(() {
                controller.performPrestige();

                // Refresh visuals after reset
                final gameState = ref.read(comprehensiveGameControllerProvider);
                final counts = <String, int>{};
                for (final gen in gameState.generators) {
                  counts[gen.id] = gen.owned;
                }
                _game.updateGenerators(counts);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Prestige completed! The universe has been reborn! 🌌'),
                      backgroundColor: Colors.purple,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              });
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

  Color _getGeneratorColor(int index) {
    final colors = [
      Colors.cyanAccent,
      Colors.greenAccent,
      Colors.yellowAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];
    return colors[index % colors.length];
  }
}
