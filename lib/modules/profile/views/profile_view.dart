import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final nameC = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Obx(() {
        final user = controller.user.value;
        if (user == null)
          return const Center(child: CircularProgressIndicator());

        nameC.text = user.name;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Center(
                child: Obx(() {
                  final photoUrl = controller.user.value?.photoUrl;
                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : const AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () => controller.uploadProfilePicture(),
                      )
                    ],
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text('Informasi Pengguna',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameC,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: user.email,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: user.role,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: user.isActive ? 'Aktif' : 'Nonaktif',
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Status Akun'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: user.createdAt.toString(),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Terdaftar Sejak'),
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.updateName(nameC.text.trim()),
                    icon: const Icon(Icons.save),
                    label: Text(controller.isLoading.value
                        ? 'Menyimpan...'
                        : 'Simpan Perubahan'),
                  )),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  final email = controller.user.value?.email;
                  if (email != null) {
                    await controller.sendResetPassword(email);
                  }
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text("Kirim Link Ganti Password"),
              ),
            ],
          ),
        );
      }),
    );
  }
}
