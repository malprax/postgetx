import 'package:get/get.dart';
import 'package:postgetx/app/data/models/capital_protection_configuration.dart';
import 'package:postgetx/app/data/models/role_permission.dart';
import 'package:postgetx/app/data/providers/local/capital_protection_configuration_provider.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

class CapitalProtectionConfigurationController extends GetxController {
  CapitalProtectionConfigurationController(
    this._provider,
    this._repository,
  );

  final CapitalProtectionConfigurationProvider _provider;
  final LocalHiveRepository _repository;

  final configuration = CapitalProtectionConfiguration.defaults.obs;
  final saving = false.obs;
  final errorMessage = ''.obs;

  void load() {
    final restored = _provider.read();
    configuration.value = restored;
    _repository.applyCapitalProtectionConfiguration(restored);
    errorMessage.value = '';
  }

  Future<bool> save(
    CapitalProtectionConfiguration next,
  ) async {
    if (!_repository.hasPermission(AppPermission.manageSettings)) {
      errorMessage.value = 'Only an owner can change capital protection rules.';
      return false;
    }

    final errors = next.validate();

    if (errors.isNotEmpty) {
      errorMessage.value = errors.join(' ');
      return false;
    }

    saving.value = true;
    errorMessage.value = '';

    try {
      await _provider.write(next);
      _repository.applyCapitalProtectionConfiguration(next);
      configuration.value = next;
      return true;
    } on FormatException catch (error) {
      errorMessage.value = error.message;
      return false;
    } finally {
      saving.value = false;
    }
  }
}
