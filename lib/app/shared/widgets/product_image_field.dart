import 'package:flutter/material.dart';

import '../../../models/category_model.dart';
import '../../../models/menu_item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'product_visual.dart';

class ProductImageField extends StatelessWidget {
  const ProductImageField({
    super.key,
    required this.product,
    this.category,
    required this.processing,
    required this.onChoose,
    required this.onRemove,
    this.errorMessage,
  });

  final MenuItemModel product;
  final CategoryModel? category;
  final bool processing;
  final Future<void> Function() onChoose;
  final VoidCallback onRemove;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Product Image',
        child: Container(
          key: const ValueKey('product-image-field'),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Product Image',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Upload a JPEG, PNG, or WebP image. Maximum 5 MB.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              ProductVisual(
                  key: const ValueKey('product-image-preview'),
                  product: product,
                  category: category,
                  size: 92),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.hasImage
                            ? product.imageName
                            : 'No product image selected',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.hasImage
                            ? 'Stored locally and available offline'
                            : 'The selected category icon is used as fallback.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(spacing: AppSpacing.sm, runSpacing: 4, children: [
                        OutlinedButton.icon(
                          key: ValueKey(product.hasImage
                              ? 'replace-product-image'
                              : 'choose-product-image'),
                          onPressed: processing ? null : onChoose,
                          icon: processing
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(product.hasImage
                              ? 'Replace Image'
                              : 'Choose Image'),
                        ),
                        if (product.hasImage)
                          TextButton.icon(
                            key: const ValueKey('remove-product-image'),
                            onPressed: processing ? null : onRemove,
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.danger),
                            label: const Text('Remove Image'),
                          ),
                      ]),
                    ]),
              ),
            ]),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(errorMessage!,
                  key: const ValueKey('product-image-error'),
                  style:
                      const TextStyle(color: AppColors.danger, fontSize: 12)),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text('Large product catalogs with images use more local storage.',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      );
}
