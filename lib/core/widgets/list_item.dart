import 'package:flutter/material.dart';

/// CustomListItem - Reusable list item component
///
/// Sử dụng cho:
/// - Settings items
/// - Achievement list
/// - Stats display
/// - Generic list displays
class CustomListItem extends StatelessWidget {
  final IconData? leadingIcon;
  final Widget? leadingWidget;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enabled;
  final EdgeInsets? padding;

  const CustomListItem({
    super.key,
    this.leadingIcon,
    this.leadingWidget,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor,
      child: ListTile(
        contentPadding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: leadingWidget ??
            (leadingIcon != null
                ? Icon(
                    leadingIcon,
                    color: iconColor ?? theme.iconTheme.color,
                  )
                : null),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: enabled ? null : Colors.grey,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: enabled ? Colors.grey[400] : Colors.grey[600],
                ),
              )
            : null,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        enabled: enabled,
      ),
    );
  }
}

/// StatListItem - Specialized list item for statistics
class StatListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;

  const StatListItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? Colors.white60,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.blue.shade300,
            ),
          ),
        ],
      ),
    );
  }
}

/// AchievementListItem - Specialized list item for achievements
class AchievementListItem extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final bool isUnlocked;
  final double progress;
  final VoidCallback? onTap;

  const AchievementListItem({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    required this.isUnlocked,
    this.progress = 0.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isUnlocked ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isUnlocked
                            ? [
                                Colors.amber.withValues(alpha: 0.3),
                                Colors.orange.withValues(alpha: 0.1),
                              ]
                            : [
                                Colors.grey.withValues(alpha: 0.2),
                                Colors.grey.withValues(alpha: 0.1),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: TextStyle(
                          fontSize: 24,
                          color: isUnlocked ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isUnlocked ? Colors.amber : Colors.grey,
                                ),
                              ),
                            ),
                            if (isUnlocked)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Progress bar (if not unlocked)
              if (!isUnlocked && progress > 0) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amber.withValues(alpha: 0.7),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// UpgradeListItem - Specialized list item for upgrades
class UpgradeListItem extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final String cost;
  final bool canAfford;
  final bool isPurchased;
  final VoidCallback? onPurchase;

  const UpgradeListItem({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    required this.cost,
    required this.canAfford,
    this.isPurchased = false,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isPurchased ? 1 : (canAfford ? 3 : 2),
      child: InkWell(
        onTap: !isPurchased && canAfford ? onPurchase : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPurchased
                        ? [
                            Colors.green.withValues(alpha: 0.3),
                            Colors.green.withValues(alpha: 0.1),
                          ]
                        : [
                            Colors.purple.withValues(alpha: 0.3),
                            Colors.purple.withValues(alpha: 0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPurchased ? Colors.grey : null,
                        decoration:
                            isPurchased ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Cost or purchased indicator
              if (isPurchased)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      cost,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: canAfford ? Colors.amber : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.bolt,
                      size: 16,
                      color: canAfford ? Colors.amber : Colors.red,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
