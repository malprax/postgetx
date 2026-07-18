import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:postgetx/app/shared/widgets/category_icon_picker.dart';
import 'package:postgetx/app/shared/widgets/product_visual.dart';
import 'package:postgetx/app/theme/category_icon_registry.dart';
import 'package:postgetx/app/data/models/cart_item_model.dart';
import 'package:postgetx/app/data/models/category_model.dart';
import 'package:postgetx/app/data/models/menu_item_model.dart';
import 'package:postgetx/app/data/models/menu_variant.dart';
import 'package:postgetx/app/data/models/order_model.dart';
import 'package:postgetx/repositories/local_hive_repository.dart';
import 'package:postgetx/app/core/services/pos_total_calculator.dart';
import 'package:postgetx/app/core/services/product_image_service.dart';
import 'package:postgetx/app/data/models/receipt_data.dart';

void main() {
  group('professional tax calculation', () {
    const calculator = PosTotalCalculator();
    final items = [
      CartItemModel(
          id: 'water',
          name: 'Water',
          size: 'Regular',
          price: 100000,
          quantity: 1),
    ];

    test('supports none percentage and fixed amount', () {
      final none = calculator.calculate(
          items: items,
          discountType: DiscountType.fixed,
          discountValue: 0,
          taxType: TaxType.none,
          taxValue: 0);
      final percentage = calculator.calculate(
          items: items,
          discountType: DiscountType.fixed,
          discountValue: 0,
          taxType: TaxType.percentage,
          taxValue: 11);
      final fixed = calculator.calculate(
          items: items,
          discountType: DiscountType.fixed,
          discountValue: 0,
          taxType: TaxType.fixedAmount,
          taxValue: 5000);
      expect(none.taxAmount, 0);
      expect(none.total, 100000);
      expect(percentage.taxAmount, 11000);
      expect(percentage.total, 111000);
      expect(fixed.taxAmount, 5000);
      expect(fixed.total, 105000);
    });

    test('applies tax after either discount type', () {
      final afterFixed = calculator.calculate(
          items: items,
          discountType: DiscountType.fixed,
          discountValue: 10000,
          taxType: TaxType.percentage,
          taxValue: 10);
      final afterPercentage = calculator.calculate(
          items: items,
          discountType: DiscountType.percentage,
          discountValue: 20,
          taxType: TaxType.fixedAmount,
          taxValue: 7500);
      expect(afterFixed.taxableAmount, 90000);
      expect(afterFixed.taxAmount, 9000);
      expect(afterFixed.total, 99000);
      expect(afterPercentage.taxableAmount, 80000);
      expect(afterPercentage.taxAmount, 7500);
      expect(afterPercentage.total, 87500);
    });

    test('old order maps parse safely without taxType', () {
      final old = OrderModel.fromMap('legacy', {
        'orderId': 'LEGACY',
        'items': items.map((item) => item.toMap()).toList(),
        'totalAmount': 110000,
        'subtotal': 100000,
        'discount': 0,
        'tax': 10000,
        'paid': 110000,
        'change': 0,
        'createdAt': DateTime(2026, 1, 1).toIso8601String(),
        'createdBy': 'legacy',
      });
      expect(old.taxType, TaxType.fixedAmount);
      expect(old.taxValue, 10000);
      expect(old.taxAmount, 10000);
    });
  });

  group('category model and registry', () {
    test('defaults old maps and round-trips stable icon names', () {
      expect(CategoryModel.fromMap('old', {'name': 'Old'}).iconName, 'other');
      final category =
          CategoryModel(id: 'cat-health', name: 'Health', iconName: 'health');
      final restored = CategoryModel.fromMap(category.id, category.toMap());
      expect(restored.iconName, 'health');
      expect(restored.copyWith(iconName: 'beauty').iconName, 'beauty');
      expect(CategoryIconRegistry.iconFor('unknown'),
          CategoryIconRegistry.defaultOption.icon);
      expect(CategoryIconRegistry.all, hasLength(18));
    });

    for (final size in [const Size(1024, 768), const Size(390, 844)]) {
      testWidgets('icon picker selects and returns an icon at ${size.width}px',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        String? result;
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () async {
                  result = await showCategoryIconPicker(context,
                      selectedName: 'other');
                },
                child: const Text('Open picker'),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('Open picker'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('category-icon-snacks')));
        await tester.tap(find.byKey(const ValueKey('select-category-icon')));
        await tester.pumpAndSettle();
        expect(result, 'snacks');
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('product image model and processor', () {
    final processor = ProductImageService();

    test('old models remain valid and explicit removal clears image', () {
      final old = MenuItemModel.fromMap('old', {
        'name': 'Old',
        'categoryId': 'other',
        'variants': [
          {'size': 'Regular', 'price': 1000}
        ],
      });
      expect(old.hasImage, isFalse);
      final pictured = old.copyWith(
          imageBase64: 'abc',
          imageMimeType: 'image/jpeg',
          imageName: 'old.jpg');
      final restored = MenuItemModel.fromMap('old', pictured.toMap());
      expect(restored.hasImage, isTrue);
      expect(
          restored
              .copyWith(imageBase64: '', imageMimeType: '', imageName: '')
              .hasImage,
          isFalse);
    });

    test('valid JPEG and PNG are normalized within storage limits', () {
      final source = img.Image(width: 1200, height: 900)
        ..clear(img.ColorRgb8(40, 120, 220));
      final jpeg = processor.processBytes(img.encodeJpg(source),
          fileName: 'photo.jpeg', mimeType: 'image/jpeg');
      final png = processor.processBytes(img.encodePng(source),
          fileName: 'photo.png', mimeType: 'image/png');
      for (final result in [jpeg, png]) {
        expect(result.success, isTrue);
        expect(result.mimeType, 'image/jpeg');
        expect(result.storedSizeBytes,
            lessThanOrEqualTo(ProductImageService.maxStoredSizeBytes));
        expect(result.width, lessThanOrEqualTo(800));
        expect(result.height, lessThanOrEqualTo(800));
      }
    });

    test('valid WebP input is accepted and normalized', () {
      final webp = base64Decode(
          'UklGRiIAAABXRUJQVlA4IBYAAAAwAQCdASoBAAEADsD+JaQAA3AAAAAA');
      final result = processor.processBytes(webp,
          fileName: 'pixel.webp', mimeType: 'image/webp');
      expect(result.success, isTrue, reason: result.errorMessage);
      expect(result.mimeType, 'image/jpeg');
    });

    test('invalid oversized corrupt and cancellation are controlled', () async {
      final invalid = processor.processBytes(Uint8List.fromList([1, 2, 3]),
          fileName: 'bad.txt', mimeType: 'text/plain');
      final oversized = processor.processBytes(
          Uint8List(ProductImageService.maxOriginalSizeBytes + 1),
          fileName: 'large.png',
          mimeType: 'image/png');
      final corrupt = processor.processBytes(
          Uint8List.fromList([0xff, 0xd8, 0xff, 0, 1, 2]),
          fileName: 'corrupt.jpg',
          mimeType: 'image/jpeg');
      final cancelled =
          await ProductImageService(pickFileOverride: () async => null)
              .pickFromGallery();
      expect(invalid.success, isFalse);
      expect(oversized.errorMessage, contains('5 MB'));
      expect(corrupt.errorMessage, contains('corrupt'));
      expect(cancelled.cancelled, isTrue);
      expect(cancelled.errorMessage, isNull);
    });

    testWidgets('corrupt image data falls back without crashing',
        (tester) async {
      final product = MenuItemModel(
          id: 'bad',
          name: 'Bad image',
          categoryId: 'missing',
          variants: [MenuVariant(size: 'Regular', price: 1000)],
          imageBase64: 'not-base64',
          imageMimeType: 'image/jpeg',
          imageName: 'bad.jpg');
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: ProductVisual(product: product, size: 80))));
      expect(
          find.byIcon(CategoryIconRegistry.defaultOption.icon), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('repository persistence', () {
    late Directory directory;
    late Box<dynamic> box;
    late LocalHiveRepository repository;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('sprint2-repository');
      Hive.init(directory.path);
      box = await Hive.openBox<dynamic>(
          'sprint2-${DateTime.now().microsecondsSinceEpoch}');
      repository = LocalHiveRepository.forBox(box);
      await repository.resetDemoData();
      await repository.login(email: 'owner@demo.local', password: 'owner123');
    });

    tearDown(() async {
      await box.close();
      await directory.delete(recursive: true);
    });

    test('category icon create and edit persist in Hive', () async {
      final created =
          await repository.addCategory('Health', iconName: 'health');
      expect(
          (await repository.getCategories())
              .firstWhere((item) => item.id == created.id)
              .iconName,
          'health');
      await repository.updateCategory(created.id, 'Beauty', iconName: 'beauty');
      expect(
          (await repository.getCategories())
              .firstWhere((item) => item.id == created.id)
              .iconName,
          'beauty');
      expect(
          (await repository.getCategories())
              .every((item) => item.iconName.isNotEmpty),
          isTrue);
    });

    test('image create preserve replace remove and reload persist', () async {
      final processed = ProductImageService().processBytes(
          img.encodeJpg(img.Image(width: 40, height: 40)
            ..clear(img.ColorRgb8(240, 90, 30))),
          fileName: 'first.jpg',
          mimeType: 'image/jpeg');
      final created = await repository.addProduct(
        name: 'Image Product',
        categoryId: 'cat-snacks',
        categoryName: 'Snacks',
        variants: [MenuVariant(size: 'Regular', price: 12000)],
        sku: 'IMG-1',
        stock: 8,
        imageBase64: processed.imageBase64,
        imageMimeType: processed.mimeType,
        imageName: processed.fileName,
      );
      var restored = (await repository.getProducts())
          .firstWhere((item) => item.id == created.id);
      expect(restored.imageBase64, processed.imageBase64);
      await repository.updateProduct(restored.copyWith(name: 'Renamed'));
      restored = (await repository.getProducts())
          .firstWhere((item) => item.id == created.id);
      expect(restored.hasImage, isTrue);
      await repository.updateProduct(
          restored.copyWith(imageBase64: '', imageMimeType: '', imageName: ''));
      restored = (await repository.getProducts())
          .firstWhere((item) => item.id == created.id);
      expect(restored.hasImage, isFalse);
    });

    test('repository rejects invalid tax independently', () async {
      final item = CartItemModel(
          id: 'water',
          name: 'Water',
          size: 'Regular',
          price: 7500,
          quantity: 1);
      final invalid = OrderModel(
          id: 'invalid-tax',
          orderId: 'INVALID-TAX',
          items: [item],
          totalAmount: 7500,
          subtotal: 7500,
          discount: 0,
          taxType: TaxType.percentage,
          taxValue: 101,
          taxAmount: 0,
          paid: 7500,
          change: 0,
          createdAt: DateTime.now(),
          createdBy: 'test',
          status: 'draft');
      final result = await repository.completeSale(invalid);
      expect(result.isSuccess, isFalse);
      expect(result.code, 'invalid_tax');
    });

    test('persisted tax is the sole receipt source', () async {
      final item = CartItemModel(
          id: 'water',
          name: 'Water',
          size: 'Regular',
          price: 7500,
          quantity: 1);
      final totals = const PosTotalCalculator().calculate(
          items: [item],
          discountType: DiscountType.fixed,
          discountValue: 0,
          taxType: TaxType.fixedAmount,
          taxValue: 500,
          amountPaid: 8000);
      final order = OrderModel(
          id: 'tax-persist',
          orderId: 'TAX-PERSIST',
          items: [item],
          totalAmount: totals.total,
          subtotal: totals.subtotal,
          discount: totals.discountAmount,
          discountType: totals.discountType,
          discountValue: totals.discountValue,
          taxableAmount: totals.taxableAmount,
          taxType: totals.taxType,
          taxValue: totals.taxValue,
          taxAmount: totals.taxAmount,
          paid: totals.amountPaid,
          change: totals.change,
          createdAt: DateTime.now(),
          createdBy: 'test',
          status: 'draft');
      final result = await repository.completeSale(order);
      expect(result.isSuccess, isTrue, reason: result.message);
      final persisted = (await repository.getTransactions())
          .firstWhere((item) => item.id == order.id);
      final receipt = ReceiptData.fromOrder(persisted);
      expect(receipt.taxType, TaxType.fixedAmount);
      expect(receipt.taxValue, 500);
      expect(receipt.taxAmount, 500);
    });
  });
}
