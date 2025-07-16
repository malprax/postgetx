import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onToggle;

  const UserCard({super.key, required this.user, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(user.isActive ? Icons.check_circle : Icons.block,
            color: user.isActive ? Colors.green : Colors.red),
        title: Text(user.name),
        subtitle:
            Text('${user.email} • ${user.role}\nTerdaftar: ${user.createdAt}'),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(user.isActive ? Icons.toggle_on : Icons.toggle_off,
              size: 32),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
