import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.isSmall = false,
  });

  Color _resolveColor(String text) {
    if (color != null) return color!;
    switch (text.toLowerCase()) {
      case 'mudah':
      case 'favorit':
        return Colors.green;
      case 'sedang':
      case 'sudah dimasak':
        return Colors.orange;
      case 'sulit':
      case 'ingin dicoba':
        return Colors.blue;
      default:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _resolveColor(label);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8.0 : 12.0,
        vertical: isSmall ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 12 : 14, color: badgeColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
