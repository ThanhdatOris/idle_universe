import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:idle_universe/core/utils/utils.dart';

/// ResourcesBar - Thanh hiển thị tài nguyên ở đầu màn hình
///
/// Hiển thị:
/// - Energy, Matter, và các tài nguyên khác
/// - Tốc độ sinh tài nguyên (/s)
/// - Icon và màu sắc phù hợp
class ResourcesBar extends StatelessWidget {
  final Decimal energy;
  final Decimal energyPerSecond;
  final Decimal? matter;
  final Decimal? matterPerSecond;
  final Decimal? entropy;
  final Decimal? darkEnergy;

  const ResourcesBar({
    super.key,
    required this.energy,
    required this.energyPerSecond,
    this.matter,
    this.matterPerSecond,
    this.entropy,
    this.darkEnergy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.purple.withValues(alpha: 0.3),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.purple.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildResourceItem(
              icon: Icons.bolt,
              label: 'Energy',
              value: energy,
              perSecond: energyPerSecond,
              color: Colors.amber,
            ),
            if (matter != null)
              _buildResourceItem(
                icon: Icons.scatter_plot,
                label: 'Matter',
                value: matter!,
                perSecond: matterPerSecond ?? Decimal.zero,
                color: Colors.cyan,
              ),
            if (entropy != null)
              _buildResourceItem(
                icon: Icons.auto_awesome,
                label: 'Entropy',
                value: entropy!,
                perSecond: null,
                color: Colors.deepPurple,
              ),
            if (darkEnergy != null)
              _buildResourceItem(
                icon: Icons.dark_mode,
                label: 'Dark Energy',
                value: darkEnergy!,
                perSecond: null,
                color: Colors.indigo,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem({
    required IconData icon,
    required String label,
    required Decimal value,
    required Decimal? perSecond,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormatter.format(value),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (perSecond != null && perSecond > Decimal.zero)
              Text(
                '+${NumberFormatter.format(perSecond)}/s',
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// CompactResourcesBar - Phiên bản thu gọn cho mobile
class CompactResourcesBar extends StatelessWidget {
  final Decimal energy;
  final Decimal energyPerSecond;
  final Decimal? matter;
  final Decimal? matterPerSecond;

  const CompactResourcesBar({
    super.key,
    required this.energy,
    required this.energyPerSecond,
    this.matter,
    this.matterPerSecond,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        border: Border(
          bottom: BorderSide(
            color: Colors.purple.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCompactItem(
              icon: Icons.bolt,
              value: energy,
              perSecond: energyPerSecond,
              color: Colors.amber,
            ),
            if (matter != null)
              _buildCompactItem(
                icon: Icons.scatter_plot,
                value: matter!,
                perSecond: matterPerSecond ?? Decimal.zero,
                color: Colors.cyan,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactItem({
    required IconData icon,
    required Decimal value,
    required Decimal perSecond,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormatter.format(value),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (perSecond > Decimal.zero)
              Text(
                '+${NumberFormatter.formatCompact(perSecond)}/s',
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
