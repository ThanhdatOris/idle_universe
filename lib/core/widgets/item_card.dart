import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:idle_universe/core/utils/utils.dart';

/// ItemCard - Card component cho Generator/Upgrade
///
/// Hiển thị:
/// - Icon và tên item
/// - Mô tả và số lượng đã sở hữu
/// - Chi phí và khả năng mua
/// - Production/Effect
class ItemCard extends StatefulWidget {
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
  final VoidCallback? onHoldRelease;
  final Color? accentColor;
  final bool isLocked;
  final String? lockReason;
  final String? milestoneInfo; // "Next: 25 owned → 2x"
  final String? predictedImpactText; // "Sẽ tăng thêm X/s"

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
    this.onHoldRelease,
    this.accentColor,
    this.isLocked = false,
    this.lockReason,
    this.milestoneInfo,
    this.predictedImpactText,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.accentColor ?? Colors.blue;

    return Card(
      elevation: widget.canAfford && !widget.isLocked ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.canAfford && !widget.isLocked
              ? color.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.2),
          width: widget.canAfford && !widget.isLocked ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.canAfford && !widget.isLocked ? widget.onPurchase : null,
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon, Name, Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon with Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
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
                            widget.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      if (widget.owned > 0)
                        Positioned(
                          right: -6,
                          bottom: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).cardColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(minWidth: 20),
                            child: Text(
                              '${widget.owned}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Name and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.isLocked
                                ? Colors.grey
                                : theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: AnimatedCrossFade(
                            firstChild: Text(
                              widget.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            secondChild: Text(
                              widget.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                            crossFadeState: _isExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lock indicator
                  if (widget.isLocked)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer: Info (Left) and Action (Right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Side: Stats & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Production/Effect
                        if (widget.productionText != null ||
                            widget.effectText != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.trending_up, size: 16, color: color),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    widget.productionText ??
                                        widget.effectText ??
                                        '',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Milestone
                        if (widget.milestoneInfo != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events,
                                    size: 16, color: Colors.purple),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    widget.milestoneInfo!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Predicted Impact
                        if (widget.predictedImpactText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              widget.predictedImpactText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right Side: Buy Button
                  if (!widget.isLocked)
                    GestureDetector(
                      onTapDown: widget.canAfford && widget.onLongPress != null
                          ? (_) => widget.onLongPress?.call()
                          : null,
                      onTapUp: (_) => widget.onHoldRelease?.call(),
                      onTapCancel: () => widget.onHoldRelease?.call(),
                      child: ElevatedButton(
                        onPressed: widget.canAfford ? widget.onPurchase : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: const Size(80, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: widget.canAfford ? 2 : 0,
                          disabledBackgroundColor: Colors.grey[800],
                          disabledForegroundColor: Colors.grey[500],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Buy',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 14,
                                  color: widget.canAfford
                                      ? Colors.white
                                      : Colors.redAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  NumberFormatter.format(widget.cost),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.canAfford
                                        ? Colors.white
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 20, color: Colors.grey),
                          SizedBox(height: 4),
                          Text(
                            'Locked',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
