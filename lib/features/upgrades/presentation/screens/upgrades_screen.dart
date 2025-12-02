import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/core/models/models.dart';
import 'package:idle_universe/core/utils/utils.dart';
import 'package:idle_universe/core/widgets/widgets.dart';
import 'package:idle_universe/features/home/presentation/logic/comprehensive_game_controller.dart';

/// UpgradesScreen - Display and purchase upgrades
class UpgradesScreen extends ConsumerWidget {
  const UpgradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(comprehensiveGameControllerProvider.notifier);
    final gameState = ref.watch(comprehensiveGameControllerProvider);
    final upgradeService = controller.upgradeService;

    if (upgradeService == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = upgradeService.getStatistics();
    final availableUpgrades = upgradeService.getAvailableUpgrades();
    final purchasedUpgrades = upgradeService.purchasedUpgrades;
    final lockedUpgrades = upgradeService.getLockedUpgrades();

    return CosmicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: 'Upgrades',
          subtitle:
              '${stats['purchased']}/${stats['total']} Purchased (${stats['percentage']}%)',
        ),
        body: CustomScrollView(
          slivers: [
            // Statistics Card
            SliverToBoxAdapter(
              child: _buildStatisticsCard(context, stats, upgradeService),
            ),

            // Available Upgrades
            if (availableUpgrades.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  'Available Upgrades',
                  Icons.shopping_cart,
                  Colors.green,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final upgrade = availableUpgrades[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUpgradeCard(
                          context,
                          upgrade,
                          controller,
                          gameState,
                          isAvailable: true,
                        ),
                      );
                    },
                    childCount: availableUpgrades.length,
                  ),
                ),
              ),
            ],

            // Purchased Upgrades
            if (purchasedUpgrades.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  'Purchased Upgrades',
                  Icons.check_circle,
                  Colors.blue,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final upgrade = purchasedUpgrades[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUpgradeCard(
                          context,
                          upgrade,
                          controller,
                          gameState,
                          isPurchased: true,
                        ),
                      );
                    },
                    childCount: purchasedUpgrades.length,
                  ),
                ),
              ),
            ],

            // Locked Upgrades
            if (lockedUpgrades.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  context,
                  'Locked Upgrades',
                  Icons.lock,
                  Colors.grey,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final upgrade = lockedUpgrades[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUpgradeCard(
                          context,
                          upgrade,
                          controller,
                          gameState,
                          isLocked: true,
                        ),
                      );
                    },
                    childCount: lockedUpgrades.length,
                  ),
                ),
              ),
            ],

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
    BuildContext context,
    Map<String, dynamic> stats,
    upgradeService,
  ) {
    final multipliers = upgradeService.getAllMultipliers();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.shopping_bag,
                label: 'Purchased',
                value: '${stats['purchased']}',
                color: Colors.blue,
              ),
              _buildStatItem(
                context,
                icon: Icons.lock_open,
                label: 'Available',
                value: '${stats['available']}',
                color: Colors.green,
              ),
              _buildStatItem(
                context,
                icon: Icons.lock,
                label: 'Locked',
                value: '${stats['locked']}',
                color: Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Active multipliers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMultiplierChip(
                context,
                'Click Power',
                '${multipliers['clickPower']!.toStringAsFixed(1)}x',
                Colors.amber,
              ),
              _buildMultiplierChip(
                context,
                'Global',
                '${multipliers['global']!.toStringAsFixed(1)}x',
                Colors.purple,
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
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

  /// Build multiplier chip
  Widget _buildMultiplierChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  /// Build upgrade card
  Widget _buildUpgradeCard(
    BuildContext context,
    Upgrade upgrade,
    controller,
    gameState, {
    bool isAvailable = false,
    bool isPurchased = false,
    bool isLocked = false,
  }) {
    final canAfford = gameState.canAfford(upgrade.cost);
    final upgradeService = controller.upgradeService;

    // Calculate predicted impact
    String? predictedImpactText;
    if (isAvailable && upgradeService != null) {
      if (upgrade.type == UpgradeType.globalMultiplier) {
        // Increase = Current PPS * (Effect - 1)
        final currentPPS = gameState.energyPerSecond;
        final increase =
            currentPPS * Decimal.parse((upgrade.effectValue - 1).toString());
        if (increase > Decimal.zero) {
          predictedImpactText = '+${NumberFormatter.format(increase)}/s';
        }
      } else if (upgrade.type == UpgradeType.generatorMultiplier &&
          upgrade.targetId != null) {
        final generator = gameState.getGenerator(upgrade.targetId!);
        if (generator != null) {
          // Calculate current total production of this generator
          final currentGenMult =
              upgradeService.getGeneratorMultiplier(generator.id);
          final globalMult = gameState.globalMultiplier;

          final genTotal = generator.getTotalProduction() *
              Decimal.parse(globalMult.toString()) *
              Decimal.parse(currentGenMult.toString());

          final increase =
              genTotal * Decimal.parse((upgrade.effectValue - 1).toString());
          if (increase > Decimal.zero) {
            predictedImpactText = '+${NumberFormatter.format(increase)}/s';
          }
        }
      } else if (upgrade.type == UpgradeType.clickPower) {
        predictedImpactText =
            '+${((upgrade.effectValue - 1) * 100).toStringAsFixed(0)}% Click Power';
      } else if (upgrade.type == UpgradeType.autoClicker) {
        predictedImpactText =
            '+${upgrade.effectValue.toStringAsFixed(0)} Clicks/s';
      }
    }

    return ItemCard(
      id: upgrade.id,
      name: upgrade.name,
      description: upgrade.description,
      icon: upgrade.icon,
      cost: upgrade.cost,
      canAfford: canAfford && isAvailable,
      owned: isPurchased ? 1 : 0,
      productionText: _getUpgradeEffectText(upgrade),
      predictedImpactText: predictedImpactText,
      onPurchase: isAvailable && canAfford
          ? () {
              final success = controller.purchaseUpgrade(upgrade.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchased: ${upgrade.name}! 🎉'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          : null,
      accentColor: isPurchased
          ? Colors.blue
          : isLocked
              ? Colors.grey
              : Colors.purple,
      isLocked: isLocked,
      lockReason: isLocked && upgrade.requirementId != null
          ? 'Requires previous upgrade'
          : null,
    );
  }

  /// Get upgrade effect text
  String _getUpgradeEffectText(Upgrade upgrade) {
    switch (upgrade.type) {
      case UpgradeType.clickPower:
        return '${upgrade.effectValue.toStringAsFixed(1)}x Click Power';
      case UpgradeType.autoClicker:
        return 'Auto-click ${upgrade.effectValue.toStringAsFixed(0)} times/sec';
      case UpgradeType.globalMultiplier:
        return '${upgrade.effectValue.toStringAsFixed(1)}x All Production';
      case UpgradeType.generatorMultiplier:
        return '${upgrade.effectValue.toStringAsFixed(1)}x Generator';
      case UpgradeType.unlockGenerator:
        return 'Unlocks New Generator';
      case UpgradeType.costReduction:
        return '${(upgrade.effectValue * 100).toStringAsFixed(0)}% Cost Reduction';
      case UpgradeType.special:
        return 'Special Effect';
    }
  }
}
