import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/features/home/presentation/logic/game_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // 1. Lấy state (để đọc)
    final gameState = ref.watch(gameControllerProvider);
    // 2. Lấy controller (để gọi hàm)
    final gameController = ref.read(gameControllerProvider.notifier);

    // 3. Xác định xem nút có bị vô hiệu hóa không
    final bool canAfford = gameState.energy >= gameState.energyUpgradeCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idle Universe Builder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Energy',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              gameState.energy.toStringAsFixed(0), // Làm tròn cho đẹp
              style: textTheme.displayLarge,
            ),
            const SizedBox(height: 10),
            Text(
              '${gameState.energyPerSecond.toStringAsFixed(0)} / giây',
              style: textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 40), // Khoảng cách

            // 4. Nút Nâng Cấp
            ElevatedButton(
              // 5. Vô hiệu hóa nút nếu không đủ tiền
              onPressed: canAfford 
                  ? () {
                      // 6. Gọi hàm từ controller
                      gameController.purchaseEnergyUpgrade();
                    } 
                  : null, // null = disabled
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Nâng cấp sản lượng',
                      style: textTheme.labelLarge,
                    ),
                    Text(
                      '(+${gameState.energyPerUpgrade.toStringAsFixed(0)} / giây)',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chi phí: ${gameState.energyUpgradeCost.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: canAfford ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}