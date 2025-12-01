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
  final int? buyAmount; // Amount to buy (for button label)

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
    this.buyAmount,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.accentColor ?? theme.colorScheme.primary;

    if (widget.isLocked) {
      return Card(
        margin: EdgeInsets.zero,
        color: Colors.grey[900]?.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lockReason ?? 'Locked',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.canAfford ? widget.onPurchase : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side: Icon & Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                      ),
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
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          '${widget.owned}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Middle: Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Name
                    Text(
                      widget.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description (Expandable)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Container(
                        color: Colors.transparent, // Expand tap area
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 2),
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
                    ),

                    const SizedBox(height: 8),

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
                                      Icon(Icons.trending_up,
                                          size: 16, color: color),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          widget.productionText ??
                                              widget.effectText ??
                                              '',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
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
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
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
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    widget.predictedImpactText!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Right Side: Buy Button
                        GestureDetector(
                          onTapDown:
                              widget.canAfford && widget.onLongPress != null
                                  ? (_) => widget.onLongPress?.call()
                                  : null,
                          onTapUp: (_) => widget.onHoldRelease?.call(),
                          onTapCancel: () => widget.onHoldRelease?.call(),
                          child: ElevatedButton(
                            onPressed:
                                widget.canAfford ? widget.onPurchase : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, // Reduced padding
                                vertical: 8,
                              ),
                              minimumSize:
                                  const Size(60, 52), // Reduced min width
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
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.buyAmount != null &&
                                              widget.buyAmount! > 1
                                          ? 'Buy ${widget.buyAmount}'
                                          : 'Buy',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
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
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          NumberFormatter.format(widget.cost),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: widget.canAfford
                                                ? Colors.white
                                                : Colors.redAccent,
                                            fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ],
                ),
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
