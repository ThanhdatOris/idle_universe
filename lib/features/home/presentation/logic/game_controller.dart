import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idle_universe/features/home/presentation/logic/game_state.dart';

// 1. Định nghĩa Notifier (giữ nguyên)
class GameController extends Notifier<GameState> {
  Timer? _gameLoop;

  @override
  GameState build() {
    _startGameLoop();
    ref.onDispose(() {
      _gameLoop?.cancel();
    });
    return GameState.initial();
  }

  void _startGameLoop() {
    _gameLoop = Timer.periodic(const Duration(seconds: 1), (timer) {
      _produceResources();
    });
  }

  void _produceResources() {
    state = state.copyWith(
      energy: state.energy + state.energyPerSecond,
      matter: state.matter + state.matterPerSecond,
    );
  }

  void purchaseEnergyUpgrade() {
    // Kiểm tra xem có đủ 'energy' không
    if (state.energy >= state.energyUpgradeCost) {
      // Lấy chi phí và tính chi phí mới
      final cost = state.energyUpgradeCost;
      
      // Công thức tính chi phí mới (Exponential scaling theo GDD)
      // Cost(n) = BaseCost * (1.15)^n
      final newCost = (cost * Decimal.parse('1.15')).ceil();
      // Cập nhật state
      state = state.copyWith(
        energy: state.energy - cost, // Trừ energy
        energyPerSecond: state.energyPerSecond + state.energyPerUpgrade, // Tăng E/s
        energyUpgradeCost: newCost, // Đặt chi phí mới
      );
    }
    // Nếu không đủ tiền, không làm gì cả
  }

  void purchaseMatterProducer() {
    // Kiểm tra xem có đủ 'ENERGY' không
    if (state.energy >= state.matterProducerCost) {
      final cost = state.matterProducerCost;
      
      // Tăng chi phí (dùng hệ số khác, ví dụ 1.20)
      final newCost = (cost * Decimal.parse('1.20')).ceil();

      state = state.copyWith(
        energy: state.energy - cost, // Trừ Energy
        matterPerSecond: state.matterPerSecond + state.matterPerProducer, // Tăng Matter/s
        matterProducerCost: newCost, // Đặt chi phí mới
      );
    }
  }
}

// 3. Provider (giữ nguyên)
final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);