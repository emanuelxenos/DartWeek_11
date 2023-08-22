import 'package:asyncstate/asyncstate.dart';
import 'package:dw_barbershop/src/core/fp/either.dart';
import 'package:dw_barbershop/src/core/providers/application_providers.dart';
import 'package:dw_barbershop/src/model/barbershop_model.dart';
import 'package:dw_barbershop/src/model/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'home_adm_state.dart';

part 'home_adm_vm.g.dart';

@riverpod
class HomeAdmVm extends _$HomeAdmVm {
  @override
  Future<HomeAdmState> build() async {
    final respository = ref.read(userRepositoryProvider);
    final BarbershopModel(id: barberShopId) =
        await ref.read(getMyBarberShopProvider.future);
    final me = await ref.watch(getMeProvider.future);

    final employeesResult = await respository.getEmployees(barberShopId);
    switch (employeesResult) {
      case Success(value: var empployessData):
        final employess = <UserModel>[];

        if (me case UserModelADM(workDays: _?, workHours: _?)) {
          employess.add(me);
        }

        employess.addAll(empployessData);

        return HomeAdmState(
            status: HomeAmdStateStatus.loaded, employees: employess);
      case Failure():
        return HomeAdmState(status: HomeAmdStateStatus.error, employees: []);
    }
  }

  Future<void> logout() => ref.read(logoutProvider.future).asyncLoader();
}
