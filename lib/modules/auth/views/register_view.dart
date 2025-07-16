import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  final bool enableRoleSelection; // 🔥 hanya untuk admin
  const RegisterView({super.key, this.enableRoleSelection = false});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final controller = Get.find<AuthController>();
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  String selectedRole = 'customer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordC,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (widget.enableRoleSelection) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedRole,
                onChanged: (val) => setState(() => selectedRole = val!),
                items: ['admin', 'staff', 'kurir', 'customer']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Pilih Role'),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.register(
                  nameC.text.trim(),
                  emailC.text.trim(),
                  passwordC.text.trim(),
                  widget.enableRoleSelection ? selectedRole : 'customer',
                );
              },
              child: const Text('Daftar'),
            ),
            if (!widget.enableRoleSelection)
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Sudah punya akun? Login'),
              ),
          ],
        ),
      ),
    );
  }
}
