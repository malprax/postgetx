import 'package:flutter/material.dart';

import '../../../data/models/customer_model.dart';

class CustomerForm extends StatefulWidget {
  const CustomerForm({
    super.key,
    this.customer,
    required this.onSubmit,
    this.submitLabel = 'Simpan',
  });

  final CustomerModel? customer;
  final Future<void> Function(CustomerFormData data) onSubmit;
  final String submitLabel;

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final customer = widget.customer;

    _nameController = TextEditingController(text: customer?.name ?? '');

    _whatsappController = TextEditingController(text: customer?.whatsapp ?? '');

    _phoneController = TextEditingController(text: customer?.phone ?? '');

    _emailController = TextEditingController(text: customer?.email ?? '');

    _addressController = TextEditingController(text: customer?.address ?? '');

    _notesController = TextEditingController(text: customer?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await widget.onSubmit(
        CustomerFormData(
          name: _nameController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer gagal disimpan: $error'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Customer',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama customer wajib diisi.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'WhatsApp',
                hintText: '081234567890',
                prefixIcon: Icon(Icons.chat_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor WhatsApp wajib diisi.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Telepon (Opsional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              textInputAction: TextInputAction.next,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(widget.submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerFormData {
  final String name;
  final String whatsapp;
  final String phone;
  final String email;
  final String address;
  final String notes;

  const CustomerFormData({
    required this.name,
    required this.whatsapp,
    required this.phone,
    required this.email,
    required this.address,
    required this.notes,
  });
}
