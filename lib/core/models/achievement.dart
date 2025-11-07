/// Achievement model - Thành tựu/Huy hiệu
///
/// Achievements unlock khi đạt điều kiện nhất định:
/// - Đạt X energy
/// - Mua X generators
/// - Click X lần
/// - Prestige X lần
class Achievement {
  final String id;
  final String name;
  final String description;

  /// Loại achievement
  final AchievementType type;

  /// Giá trị target (ví dụ: click 100 lần → targetValue = 100)
  final double targetValue;

  /// Đã unlock chưa
  bool isUnlocked;

  /// Icon cho UI
  final String icon;

  /// Thưởng khi unlock (optional) - có thể là prestige points
  final Map<String, dynamic>? reward;

  /// Thời gian unlock
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetValue,
    this.isUnlocked = false,
    this.icon = '🏆',
    this.reward,
    this.unlockedAt,
  });

  /// Kiểm tra đã đạt achievement chưa (dựa vào giá trị hiện tại)
  bool checkUnlock(double currentValue) {
    if (isUnlocked) return false;
    return currentValue >= targetValue;
  }

  /// Unlock achievement
  void unlock() {
    if (!isUnlocked) {
      isUnlocked = true;
      unlockedAt = DateTime.now();
    }
  }

  /// Progress % (0.0 - 1.0)
  double getProgress(double currentValue) {
    if (isUnlocked) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  // === Serialization ===

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'targetValue': targetValue,
      'isUnlocked': isUnlocked,
      'icon': icon,
      'reward': reward,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      targetValue: (json['targetValue'] as num).toDouble(),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      icon: json['icon'] as String? ?? '🏆',
      reward: json['reward'] as Map<String, dynamic>?,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    AchievementType? type,
    double? targetValue,
    bool? isUnlocked,
    String? icon,
    Map<String, dynamic>? reward,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      icon: icon ?? this.icon,
      reward: reward ?? this.reward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  String toString() {
    return 'Achievement(id: $id, name: $name, unlocked: $isUnlocked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Loại achievement
enum AchievementType {
  /// Tổng energy kiếm được
  totalEnergy,

  /// Số lần click
  totalClicks,

  /// Số generators đã mua
  totalGenerators,

  /// Số lần prestige
  prestigeCount,

  /// Energy per second đạt được
  energyPerSecond,

  /// Số upgrades đã mua
  totalUpgrades,

  /// Thời gian chơi (giờ)
  playTime,

  /// Đặc biệt (hidden achievements)
  special,
}
