import 'package:postgetx/app/data/models/user_model.dart';
import 'package:postgetx/app/data/models/role_permission.dart';

abstract class AuthRepository {
  UserModel? get currentUser;
  Future<UserModel> login({required String email, required String password});
  Future<UserModel?> restoreSession();
  bool hasPermission(AppPermission permission);
  Future<void> logout();
}
