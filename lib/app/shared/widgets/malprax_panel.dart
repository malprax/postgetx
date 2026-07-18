import 'package:flutter/material.dart';

import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

class MalpraxPanel extends StatelessWidget {
  const MalpraxPanel({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding,
    this.headerColor,
    this.headerForegroundColor,
  });
  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsets? padding;
  final Color? headerColor;
  final Color? headerForegroundColor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final body = Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          );
          final content = title == null
              ? body
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: headerColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: headerForegroundColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(child: trailing!),
                        ],
                      ]),
                    ),
                    if (constraints.hasBoundedHeight)
                      Expanded(child: body)
                    else
                      body,
                  ],
                );
          return Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: Theme.of(context).dividerColor),
            ),
            child: content,
          );
        },
      );
}
