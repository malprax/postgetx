import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/role_permission.dart';
import '../../../models/user_model.dart';
import '../../../repositories/local_hive_repository.dart';

class UserFormView extends StatefulWidget {
  final UserModel? user;

  const UserFormView({
    super.key,
    this.user,
  });

  @override
  State<UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends State<UserFormView> {
  final _formKey = GlobalKey<FormState>();
  final repository = Get.find<LocalHiveRepository>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  String selectedRole = UserRole.staff;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final user = widget.user;

    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      selectedRole = user.role;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || isSaving) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final now = DateTime.now();
      final existing = widget.user;

      final user = UserModel(
        id: existing?.id ?? 'user-${now.microsecondsSinceEpoch}',
        name: nameController.text.trim(),
        email: emailController.text.trim().toLowerCase(),
        role: selectedRole,
        isActive: existing?.isActive ?? true,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        passwordHash: existing?.passwordHash ?? '',
        photoUrl: existing?.photoUrl ?? '',
      );

      await repository.saveUser(user);

      Get.back(result: true);
    } on FormatException catch (error) {
      Get.snackbar(
        'Data tidak valid',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Gagal menyimpan',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user == null ? 'Tambah Pengguna' : 'Edit Pengguna',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty || !email.contains('@')) {
                    return 'Email tidak valid';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                ),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.owner,
                    child: Text('OWNER'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.staff,
                    child: Text('STAFF'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving ? null : _save,
                child: Text(
                  isSaving ? 'Menyimpan...' : 'Simpan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
