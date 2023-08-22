import 'package:dw_barbershop/src/core/constants/local_storage_keys.dart';
import 'package:dw_barbershop/src/core/providers/application_providers.dart';
import 'package:dw_barbershop/src/model/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'splash_vm.g.dart';

enum SplashStateStatus {
  inintial,
  login,
  loggedADM,
  loggedEmployee,
  error,
}

@riverpod
class SplashVm extends _$SplashVm {
  @override
  Future<SplashStateStatus> build() async {
    final sp = await SharedPreferences.getInstance();
    if (sp.containsKey(LocalStorageKeys.accessToken)) {
      ref.invalidate(getMeProvider);
      ref.invalidate(getMyBarberShopProvider);

      final userModel = await ref.watch(getMeProvider.future);

      try {
        return switch (userModel) {
          UserModelADM() => SplashStateStatus.loggedADM,
          UserModelEmployee() => SplashStateStatus.loggedEmployee,
        };
      } catch (e) {
        return SplashStateStatus.login;
      }
    }

    return SplashStateStatus.login;
  }
}
