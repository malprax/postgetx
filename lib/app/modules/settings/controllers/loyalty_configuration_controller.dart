import 'package:get/get.dart';
import 'package:postgetx/app/data/models/loyalty_configuration.dart';
import 'package:postgetx/app/data/models/role_permission.dart';
import 'package:postgetx/app/data/providers/local/loyalty_configuration_provider.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

class LoyaltyConfigurationController extends GetxController {
  LoyaltyConfigurationController(
    this._provider,
    this._repository,
  );

  final LoyaltyConfigurationProvider _provider;
  final LocalHiveRepository _repository;

  final configuration = LoyaltyConfiguration.defaults.obs;
  final saving = false.obs;
  final errorMessage = ''.obs;

  void load() {
    final restored = _provider.read();
    configuration.value = restored;
    _repository.applyLoyaltyConfiguration(restored);
    errorMessage.value = '';
  }

  Future<bool> save(
    LoyaltyConfiguration nextConfiguration,
  ) async {
    if (!_repository.hasPermission(AppPermission.manageSettings)) {
      errorMessage.value = 'Only an owner can change loyalty configuration.';
      return false;
    }

    final errors = nextConfiguration.validate();

    if (errors.isNotEmpty) {
      errorMessage.value = errors.join(' ');
      return false;
    }

    saving.value = true;
    errorMessage.value = '';

    try {
      await _provider.write(nextConfiguration);
      _repository.applyLoyaltyConfiguration(nextConfiguration);
      configuration.value = nextConfiguration;
      return true;
    } on FormatException catch (error) {
      errorMessage.value = error.message;
      return false;
    } finally {
      saving.value = false;
    }
  }
}
