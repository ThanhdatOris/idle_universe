import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:idle_universe/core/utils/utils.dart';

/// ItemCard - Card component cho Generator/Upgrade
///
/// Hiển thị:
/// - Icon và tên item
/// - Mô tả và số lượng đã sở hữu
/// - Chi phí và khả năng mua
/// - Production/Effect
class ItemCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Decimal cost;
  final bool canAfford;
  final int owned;
  final String? productionText;
  final String? effectText;
  final VoidCallback? onPurchase;
  final VoidCallback? onLongPress;
  final Color? accentColor;
  final bool isLocked;
  final String? lockReason;

  const ItemCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cost,
    required this.canAfford,
    this.owned = 0,
    this.productionText,
    this.effectText,
    this.onPurchase,
    this.onLongPress,
    this.accentColor,
    this.isLocked = false,
    this.lockReason,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? Colors.blue;

    return Card(
      elevation: canAfford && !isLocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: canAfford && !isLocked
              ? color.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.2),
          width: canAfford && !isLocked ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: canAfford && !isLocked ? onPurchase : null,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, Name, Owned count
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and owned count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLocked
                                ? Colors.grey
                                : theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        if (owned > 0)
                          Text(
                            'Owned: $owned',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Lock indicator
                  if (isLocked)
                    Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 20,
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Production/Effect info
              if (productionText != null || effectText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        productionText ?? effectText ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Cost and purchase button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cost
                  Row(
                    children: [
                      Icon(
                        Icons.bolt,
                        size: 16,
                        color: canAfford ? Colors.amber : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormatter.format(cost),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: canAfford ? Colors.amber : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Purchase button
                  if (!isLocked)
                    ElevatedButton(
                      onPressed: canAfford ? onPurchase : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Buy'),
                    )
                  else
                    Tooltip(
                      message: lockReason ?? 'Locked',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Locked',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
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

/// CompactItemCard - Phiên bản thu gọn cho danh sách dài
class CompactItemCard extends StatelessWidget {
  final String name;
  final String icon;
  final Decimal cost;
  final bool canAfford;
  final int owned;
  final VoidCallback? onPurchase;
  final Color? accentColor;

  const CompactItemCard({
    super.key,
    required this.name,
    required this.icon,
    required this.cost,
    required this.canAfford,
    this.owned = 0,
    this.onPurchase,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Colors.blue;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Text(icon, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Cost: ${NumberFormatter.format(cost)}',
        style: TextStyle(
          color: canAfford ? Colors.amber : Colors.red,
        ),
      ),
      trailing: owned > 0
          ? Chip(
              label: Text('$owned'),
              backgroundColor: color.withValues(alpha: 0.3),
            )
          : null,
      onTap: canAfford ? onPurchase : null,
      enabled: canAfford,
    );
  }
}
