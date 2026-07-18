import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/category_icon_registry.dart';

Future<String?> showCategoryIconPicker(
  BuildContext context, {
  required String selectedName,
}) {
  if (MediaQuery.sizeOf(context).width < 600) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: .88,
        child: _CategoryIconPicker(selectedName: selectedName),
      ),
    );
  }
  return showDialog<String>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 650),
        child: _CategoryIconPicker(selectedName: selectedName),
      ),
    ),
  );
}

class _CategoryIconPicker extends StatefulWidget {
  const _CategoryIconPicker({required this.selectedName});
  final String selectedName;

  @override
  State<_CategoryIconPicker> createState() => _CategoryIconPickerState();
}

class _CategoryIconPickerState extends State<_CategoryIconPicker> {
  late String selected = widget.selectedName;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Choose Category Icon',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text('Select a clear visual identifier for this category.',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth < 420 ? 3 : 4;
              return GridView.builder(
                key: const ValueKey('category-icon-grid'),
                itemCount: CategoryIconRegistry.all.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 104,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                ),
                itemBuilder: (_, index) {
                  final option = CategoryIconRegistry.all[index];
                  final active = option.name == selected;
                  return InkWell(
                    key: ValueKey('category-icon-${option.name}'),
                    onTap: () => setState(() => selected = option.name),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary.withValues(alpha: .14)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: active
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                          width: active ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(option.icon,
                              size: 31,
                              color: active ? AppColors.primary : null),
                          const SizedBox(height: AppSpacing.sm),
                          Text(option.label,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              key: const ValueKey('select-category-icon'),
              onPressed: () => Navigator.pop(context, selected),
              child: const Text('Select'),
            ),
          ]),
        ]),
      );
}
