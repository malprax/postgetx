import 'package:flutter/material.dart';

import 'malprax_panel.dart';

class MalpraxStatCard extends StatelessWidget {
  const MalpraxStatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  @override
  Widget build(BuildContext context) => MalpraxPanel(
          child: Row(children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800))
        ]))
      ]));
}
