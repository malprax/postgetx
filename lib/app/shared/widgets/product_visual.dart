import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../models/category_model.dart';
import '../../../models/menu_item_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/category_icon_registry.dart';

abstract final class ProductVisualResolver {
  static final Map<String, Uint8List?> _decoded = {};

  static Uint8List? imageBytes(MenuItemModel product) {
    final source = product.imageBase64.trim();
    if (source.isEmpty) return null;
    final cacheKey = '${product.id}:${source.length}:${source.hashCode}';
    return _decoded.putIfAbsent(cacheKey, () {
      try {
        final bytes = base64Decode(source);
        return bytes.isEmpty ? null : bytes;
      } catch (_) {
        return null;
      }
    });
  }

  static IconData fallbackIcon(CategoryModel? category) =>
      CategoryIconRegistry.iconFor(category?.iconName);

  static void clearCache() => _decoded.clear();
}

class ProductVisual extends StatelessWidget {
  const ProductVisual({
    super.key,
    required this.product,
    this.category,
    required this.size,
    this.fit = BoxFit.cover,
  });

  final MenuItemModel product;
  final CategoryModel? category;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final bytes = ProductVisualResolver.imageBytes(product);
    final fallback = _FallbackVisual(category: category, size: size);
    return Semantics(
      image: true,
      label: product.hasImage
          ? '${product.name} product image'
          : '${product.name} category icon',
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary.withValues(alpha: .18)),
        ),
        child: bytes == null
            ? fallback
            : Image.memory(
                bytes,
                fit: fit,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class _FallbackVisual extends StatelessWidget {
  const _FallbackVisual({required this.category, required this.size});
  final CategoryModel? category;
  final double size;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: .18),
              AppColors.primary.withValues(alpha: .03),
            ],
          ),
        ),
        child: Icon(
          ProductVisualResolver.fallbackIcon(category),
          size: size * .52,
          color: AppColors.primary,
        ),
      );
}
