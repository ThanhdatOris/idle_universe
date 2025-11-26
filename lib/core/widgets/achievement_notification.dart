import 'package:flutter/material.dart';
import 'package:idle_universe/core/models/models.dart';

/// AchievementNotification - Animated notification when achievement unlocks
class AchievementNotification extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementNotification({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementNotification> createState() =>
      _AchievementNotificationState();
}

class _AchievementNotificationState extends State<AchievementNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: _dismiss,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withValues(alpha: 0.95),
                Colors.orange.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.amber.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon with glow effect
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  widget.achievement.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),

              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ACHIEVEMENT UNLOCKED!',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.achievement.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.achievement.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.achievement.reward != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reward: ${widget.achievement.reward!['prestigePoints']} Prestige Points',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Close button
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _dismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AchievementNotificationOverlay - Manages multiple achievement notifications
class AchievementNotificationOverlay extends StatefulWidget {
  final Widget child;

  const AchievementNotificationOverlay({
    super.key,
    required this.child,
  });

  static AchievementNotificationOverlayState? of(BuildContext context) {
    return context
        .findAncestorStateOfType<AchievementNotificationOverlayState>();
  }

  @override
  State<AchievementNotificationOverlay> createState() =>
      AchievementNotificationOverlayState();
}

class AchievementNotificationOverlayState
    extends State<AchievementNotificationOverlay> {
  final List<Achievement> _queue = [];
  Achievement? _currentAchievement;

  /// Show achievement notification
  void showAchievement(Achievement achievement) {
    if (_currentAchievement == null) {
      setState(() {
        _currentAchievement = achievement;
      });
    } else {
      _queue.add(achievement);
    }
  }

  void _onDismiss() {
    setState(() {
      _currentAchievement = null;
    });

    // Show next in queue
    if (_queue.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _queue.isNotEmpty) {
          setState(() {
            _currentAchievement = _queue.removeAt(0);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentAchievement != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: AchievementNotification(
              achievement: _currentAchievement!,
              onDismiss: _onDismiss,
            ),
          ),
      ],
    );
  }
}
