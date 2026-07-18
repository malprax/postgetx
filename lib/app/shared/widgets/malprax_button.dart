import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class MalpraxButton extends StatelessWidget {
  const MalpraxButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.destructive = false,
      this.filled = false,
      this.accent = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool destructive;
  final bool filled;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1))
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Flexible(
                child:
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis))
          ]);
    return filled
        ? FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: destructive
                  ? Theme.of(context).colorScheme.error
                  : accent
                      ? AppColors.accent
                      : null,
              foregroundColor: Colors.white,
            ),
            onPressed: onPressed,
            child: child)
        : OutlinedButton(
            style: destructive
                ? OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error)
                : null,
            onPressed: onPressed,
            child: child);
  }
}
