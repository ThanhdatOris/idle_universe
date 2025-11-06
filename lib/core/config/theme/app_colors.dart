import 'package:flutter/material.dart';

/// App color palette - Bảng màu cosmic tech cho Idle Universe Builder
/// Tách riêng để dễ quản lý và tái sử dụng
class AppColors {
  // === DARK THEME COLORS (Cosmic Dark) ===
  static const Color darkBackground = Color(0xFF121212); // Nền đen sâu
  static const Color darkSurface = Color(0xFF1E1E1E); // Card/surface tối
  static const Color darkPrimary = Colors.deepPurple; // Accent chính (tím)
  static const Color darkSecondary = Colors.cyanAccent; // Accent phụ (cyan)
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;

  // === LIGHT THEME COLORS (Cosmic Light) ===
  static const Color lightBackground = Color(0xFFF5F5F5); // Nền xám nhạt
  static const Color lightSurface = Colors.white; // Card trắng
  static const Color lightPrimary = Color(0xFF1976D2); // Accent chính (xanh lam)
  static const Color lightSecondary = Color(0xFF00BCD4); // Accent phụ (cyan)
  static const Color lightTextPrimary = Colors.black87;
  static const Color lightTextSecondary = Colors.black54;

  // === RESOURCE COLORS (dùng chung cho cả dark/light) ===
  /// Màu cho Energy (vàng - năng lượng)
  static const Color energyColor = Color(0xFFFFEB3B); // Yellow 500

  /// Màu cho Matter (xanh lam - vật chất)
  static const Color matterColor = Color(0xFF2196F3); // Blue 500

  /// Màu cho Entropy (đỏ - hỗn loạn)
  static const Color entropyColor = Color(0xFFF44336); // Red 500

  /// Màu cho Dark Energy (tím đậm - năng lượng tối)
  static const Color darkEnergyColor = Color(0xFF9C27B0); // Purple 500

  // === UI STATE COLORS ===
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color infoColor = Color(0xFF2196F3); // Blue

  // === TIER COLORS (gradient cho từng tier) ===
  static const List<Color> subatomicGradient = [
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
  ];

  static const List<Color> atomicGradient = [
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
  ];

  static const List<Color> planetaryGradient = [
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
  ];

  static const List<Color> galacticGradient = [
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
  ];

  static const List<Color> cosmicGradient = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
  ];

  // === HELPER: Lấy màu resource theo tên ===
  static Color getResourceColor(String resourceName) {
    switch (resourceName.toLowerCase()) {
      case 'energy':
        return energyColor;
      case 'matter':
        return matterColor;
      case 'entropy':
        return entropyColor;
      case 'darkenergy':
      case 'dark energy':
        return darkEnergyColor;
      default:
        return Colors.grey;
    }
  }

  // === HELPER: Lấy gradient theo tier ===
  static List<Color> getTierGradient(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'subatomic':
        return subatomicGradient;
      case 'atomic':
        return atomicGradient;
      case 'planetary':
        return planetaryGradient;
      case 'galactic':
        return galacticGradient;
      case 'cosmic':
        return cosmicGradient;
      default:
        return [Colors.grey, Colors.grey];
    }
  }
}
