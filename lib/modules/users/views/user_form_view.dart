import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

class UserFormView extends StatefulWidget {
  final UserModel? user;
  const UserFormView({super.key, this.user});

  @override
  State<UserFormView> createState() => _UserFormViewState();
}

class _UserFormViewState extends State<UserFormView> {
  final _formKey = GlobalKey<FormState>();
  final userService = UserService();

  final nameC = TextEditingController();
  final emailC = TextEditingController();
  String selectedRole = 'customer';

  @override
  void initState() {
    if (widget.user != null) {
      nameC.text = widget.user!.name;
      emailC.text = widget.user!.email;
      selectedRole = widget.user!.role;
    }
    super.initState();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid =
        widget.user?.uid ?? DateTime.now().millisecondsSinceEpoch.toString();

    final newUser = UserModel(
      uid: uid,
      name: nameC.text.trim(),
      email: emailC.text.trim(),
      role: selectedRole,
      isActive: true,
      createdAt: widget.user?.createdAt ?? DateTime.now(),
    );

    await userService.saveUser(newUser);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.user != null ? 'Edit Pengguna' : 'Tambah Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: emailC,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) => val == null || !val.contains('@')
                    ? 'Email tidak valid'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                onChanged: (val) => setState(() => selectedRole = val!),
                items: ['admin', 'staff', 'kurir', 'customer']
                    .map((role) => DropdownMenuItem(
                        value: role, child: Text(role.toUpperCase())))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
