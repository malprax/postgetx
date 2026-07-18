import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgetx/models/customer_model.dart';
import 'package:postgetx/modules/customers/widgets/customer_form.dart';

void main() {
  Widget buildSubject({
    CustomerModel? customer,
    Future<void> Function(CustomerFormData data)? onSubmit,
    String submitLabel = 'Simpan',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CustomerForm(
          customer: customer,
          submitLabel: submitLabel,
          onSubmit: onSubmit ?? (_) async {},
        ),
      ),
    );
  }

  testWidgets('renders all customer form fields', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Nama Customer'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Telepon (Opsional)'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Alamat'), findsOneWidget);
    expect(find.text('Catatan'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
  });

  testWidgets(
    'requires customer name and WhatsApp before submitting',
    (tester) async {
      var submitCount = 0;

      await tester.pumpWidget(
        buildSubject(
          onSubmit: (_) async {
            submitCount++;
          },
        ),
      );

      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(
        find.text('Nama customer wajib diisi.'),
        findsOneWidget,
      );

      expect(
        find.text('Nomor WhatsApp wajib diisi.'),
        findsOneWidget,
      );

      expect(submitCount, 0);
    },
  );

  testWidgets('submits trimmed customer form data', (tester) async {
    CustomerFormData? submittedData;

    await tester.pumpWidget(
      buildSubject(
        onSubmit: (data) async {
          submittedData = data;
        },
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(
      fields.at(0),
      '  Budi Santoso  ',
    );

    await tester.enterText(
      fields.at(1),
      ' 081234567890 ',
    );

    await tester.enterText(
      fields.at(2),
      ' 0411123456 ',
    );

    await tester.enterText(
      fields.at(3),
      ' budi@example.com ',
    );

    await tester.enterText(
      fields.at(4),
      ' Makassar ',
    );

    await tester.enterText(
      fields.at(5),
      ' Pelanggan grosir ',
    );

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(submittedData, isNotNull);
    expect(submittedData!.name, 'Budi Santoso');
    expect(submittedData!.whatsapp, '081234567890');
    expect(submittedData!.phone, '0411123456');
    expect(submittedData!.email, 'budi@example.com');
    expect(submittedData!.address, 'Makassar');
    expect(submittedData!.notes, 'Pelanggan grosir');
  });

  testWidgets('prefills customer data when editing', (tester) async {
    final customer = CustomerModel(
      id: 'customer-1',
      membershipId: 'MBR-000001',
      name: 'Budi Santoso',
      whatsapp: '081234567890',
      normalizedWhatsapp: '6281234567890',
      phone: '0411123456',
      normalizedPhone: '62411123456',
      email: 'budi@example.com',
      address: 'Makassar',
      notes: 'Pelanggan grosir',
    );

    await tester.pumpWidget(
      buildSubject(customer: customer),
    );

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);
    expect(find.text('0411123456'), findsOneWidget);
    expect(find.text('budi@example.com'), findsOneWidget);
    expect(find.text('Makassar'), findsOneWidget);
    expect(find.text('Pelanggan grosir'), findsOneWidget);
  });

  testWidgets('submits edited customer data', (tester) async {
    CustomerFormData? submittedData;

    final customer = CustomerModel(
      id: 'customer-1',
      membershipId: 'MBR-000001',
      name: 'Budi Santoso',
      whatsapp: '081234567890',
      normalizedWhatsapp: '6281234567890',
    );

    await tester.pumpWidget(
      buildSubject(
        customer: customer,
        onSubmit: (data) async {
          submittedData = data;
        },
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(
      fields.at(0),
      'Budi Updated',
    );

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(submittedData, isNotNull);
    expect(submittedData!.name, 'Budi Updated');
    expect(submittedData!.whatsapp, '081234567890');
  });

  testWidgets('disables submit button while saving', (tester) async {
    final completer = Completer<void>();
    var submitCount = 0;

    await tester.pumpWidget(
      buildSubject(
        onSubmit: (_) {
          submitCount++;
          return completer.future;
        },
      ),
    );

    final fields = find.byType(TextFormField);

    await tester.enterText(
      fields.at(0),
      'Budi Santoso',
    );

    await tester.enterText(
      fields.at(1),
      '081234567890',
    );

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );

    final savingButton = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );

    expect(savingButton.onPressed, isNull);
    expect(submitCount, 1);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(submitCount, 1);

    completer.complete();

    await tester.pumpAndSettle();

    expect(submitCount, 1);
  });

  testWidgets(
    'restores submit button when submission throws',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          onSubmit: (_) async {
            throw StateError('Save failed');
          },
        ),
      );

      final fields = find.byType(TextFormField);

      await tester.enterText(
        fields.at(0),
        'Budi Santoso',
      );

      await tester.enterText(
        fields.at(1),
        '081234567890',
      );

      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(
        tester.takeException(),
        isA<StateError>(),
      );

      await tester.pump();

      final button = tester.widget<FilledButton>(
        find.byType(FilledButton),
      );

      expect(button.onPressed, isNotNull);
    },
  );
}
