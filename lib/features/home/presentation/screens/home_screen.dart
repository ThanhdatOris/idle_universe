import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/features/home/presentation/logic/game_controller.dart';
import 'package:idle_universe/core/widgets/widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final gameState = ref.watch(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);

    // Tính toán khả năng mua
    final bool canAffordEnergyUpgrade = gameState.energy >= gameState.energyUpgradeCost;
    // 1. Tính toán cho Matter
    final bool canAffordMatterProducer = gameState.energy >= gameState.matterProducerCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idle Universe Builder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Hiển thị Energy (Giữ nguyên) ---
            Text('Energy', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              gameState.energy.toStringAsFixed(0),
              style: textTheme.displayLarge,
            ),
            Text(
              '${gameState.energyPerSecond.toStringAsFixed(0)} / giây',
              style: textTheme.bodyMedium,
            ),

            // 2. --- Hiển thị Matter (Mới) ---
            const SizedBox(height: 30), // Khoảng cách
            Text('Matter', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              gameState.matter.toStringAsFixed(0),
              style: textTheme.displayLarge?.copyWith(
                color: Colors.amberAccent, // Màu khác cho Matter
              ), 
            ),
            Text(
              '${gameState.matterPerSecond.toStringAsFixed(0)} / giây',
              style: textTheme.bodyMedium,
            ),

            const SizedBox(height: 40), // Khoảng cách

            // 3. --- Hàng Nút Bấm (Mới) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // --- Nút Nâng Cấp Energy ---
                ElevatedButton(
                  onPressed: canAffordEnergyUpgrade
                      ? gameController.purchaseEnergyUpgrade
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text('Nâng cấp Energy', style: textTheme.labelLarge),
                        Text(
                          '(+${gameState.energyPerUpgrade.toStringAsFixed(0)} /s)',
                        ),
                        Text(
                          'Cost: ${gameState.energyUpgradeCost.toStringAsFixed(0)} E',
                          style: TextStyle(
                            color: canAffordEnergyUpgrade ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. --- Nút Nâng Cấp Matter (Mới) ---
                ElevatedButton(
                  onPressed: canAffordMatterProducer
                      ? gameController.purchaseMatterProducer
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Text('Mua Máy Matter', style: textTheme.labelLarge),
                        Text(
                          '(+${gameState.matterPerProducer.toStringAsFixed(0)} /s)',
                        ),
                        Text(
                          'Cost: ${gameState.matterProducerCost.toStringAsFixed(0)} E', // Cost bằng Energy
                          style: TextStyle(
                            color: canAffordMatterProducer ? Colors.greenAccent : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}