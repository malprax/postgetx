import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:postgetx/modules/users/controllers/user_controller.dart';

import '../../../models/user_model.dart';
import 'user_form_view.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UsersController());

    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pengguna')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const UserFormView()),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        final users = controller.userList;
        if (users.isEmpty)
          return const Center(child: Text('Belum ada pengguna.'));

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (_, i) {
            final user = users[i];
            return ListTile(
              title: Text(user.name),
              subtitle: Text('${user.email} • ${user.role}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                        user.isActive ? Icons.toggle_on : Icons.toggle_off),
                    onPressed: () => controller.toggleStatus(user),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Get.to(() => UserFormView(user: user)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => controller.deleteUser(user.uid),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
