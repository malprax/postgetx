import 'package:get/get.dart';
import 'package:postgetx/app/data/models/loyalty_tier.dart';
import 'package:postgetx/app/data/models/role_permission.dart';
import 'package:postgetx/app/data/providers/local/loyalty_tier_rules_provider.dart';
import 'package:postgetx/app/data/repositories/local_hive_repository.dart';

typedef ReadLoyaltyTierRules = LoyaltyTierRules Function();
typedef WriteLoyaltyTierRules = Future<void> Function(
  LoyaltyTierRules rules,
);
typedef ApplyLoyaltyTierRules = void Function(
  LoyaltyTierRules rules,
);
typedef CanManageLoyaltyTierRules = bool Function();

class LoyaltyTierRulesController extends GetxController {
  LoyaltyTierRulesController({
    required ReadLoyaltyTierRules readRules,
    required WriteLoyaltyTierRules writeRules,
    required ApplyLoyaltyTierRules applyRules,
    required CanManageLoyaltyTierRules canManage,
  })  : _readRules = readRules,
        _writeRules = writeRules,
        _applyRules = applyRules,
        _canManage = canManage;

  factory LoyaltyTierRulesController.local(
    LoyaltyTierRulesProvider provider,
    LocalHiveRepository repository,
  ) {
    return LoyaltyTierRulesController(
      readRules: provider.read,
      writeRules: provider.write,
      applyRules: repository.applyLoyaltyTierRules,
      canManage: () => repository.hasPermission(
        AppPermission.manageSettings,
      ),
    );
  }

  final ReadLoyaltyTierRules _readRules;
  final WriteLoyaltyTierRules _writeRules;
  final ApplyLoyaltyTierRules _applyRules;
  final CanManageLoyaltyTierRules _canManage;

  final rules = LoyaltyTierRules.defaults.obs;
  final saving = false.obs;
  final errorMessage = ''.obs;

  void load() {
    final restored = _readRules();
    rules.value = restored;
    _applyRules(restored);
    errorMessage.value = '';
  }

  Future<bool> save(LoyaltyTierRules nextRules) async {
    if (!_canManage()) {
      errorMessage.value = 'Only an owner can change loyalty tier rules.';
      return false;
    }

    final errors = nextRules.validate();

    if (errors.isNotEmpty) {
      errorMessage.value = errors.join(' ');
      return false;
    }

    saving.value = true;
    errorMessage.value = '';

    try {
      await _writeRules(nextRules);
      _applyRules(nextRules);
      rules.value = nextRules;
      return true;
    } on FormatException catch (error) {
      errorMessage.value = error.message;
      return false;
    } finally {
      saving.value = false;
    }
  }
}
