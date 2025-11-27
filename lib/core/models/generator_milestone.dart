/// GeneratorMilestone - Milestone rewards for owning X generators
///
/// When a player owns a certain number of a generator,
/// they unlock a permanent multiplier bonus
class GeneratorMilestone {
  final int threshold; // Number of generators needed (25, 50, 100, 250, 500)
  final double multiplier; // Production multiplier (2x, 3x, 5x, etc.)
  final String description; // Description of the bonus
  bool isUnlocked; // Whether this milestone has been reached

  GeneratorMilestone({
    required this.threshold,
    required this.multiplier,
    required this.description,
    this.isUnlocked = false,
  });

  /// Check if milestone should be unlocked
  bool checkUnlock(int owned) {
    if (!isUnlocked && owned >= threshold) {
      isUnlocked = true;
      return true; // Newly unlocked
    }
    return false;
  }

  /// Get display text for milestone
  String get displayText {
    return '$threshold owned → ${multiplier.toStringAsFixed(1)}x production';
  }

  // === Serialization ===

  Map<String, dynamic> toJson() {
    return {
      'threshold': threshold,
      'multiplier': multiplier,
      'description': description,
      'isUnlocked': isUnlocked,
    };
  }

  factory GeneratorMilestone.fromJson(Map<String, dynamic> json) {
    return GeneratorMilestone(
      threshold: json['threshold'] as int,
      multiplier: (json['multiplier'] as num).toDouble(),
      description: json['description'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  GeneratorMilestone copyWith({
    int? threshold,
    double? multiplier,
    String? description,
    bool? isUnlocked,
  }) {
    return GeneratorMilestone(
      threshold: threshold ?? this.threshold,
      multiplier: multiplier ?? this.multiplier,
      description: description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  @override
  String toString() {
    return 'Milestone($threshold → ${multiplier}x, unlocked: $isUnlocked)';
  }
}

/// Default milestones for all generators
class MilestoneConfig {
  static List<GeneratorMilestone> getDefaultMilestones() {
    return [
      GeneratorMilestone(
        threshold: 25,
        multiplier: 2.0,
        description: 'Double production',
      ),
      GeneratorMilestone(
        threshold: 50,
        multiplier: 2.0,
        description: 'Double production again',
      ),
      GeneratorMilestone(
        threshold: 100,
        multiplier: 2.0,
        description: 'Double production again',
      ),
      GeneratorMilestone(
        threshold: 250,
        multiplier: 3.0,
        description: 'Triple production',
      ),
      GeneratorMilestone(
        threshold: 500,
        multiplier: 5.0,
        description: 'Quintuple production',
      ),
    ];
  }
}
