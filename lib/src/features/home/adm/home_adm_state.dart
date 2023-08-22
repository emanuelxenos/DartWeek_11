import 'package:dw_barbershop/src/model/user_model.dart';

enum HomeAmdStateStatus { loaded, error }

class HomeAdmState {
  final HomeAmdStateStatus status;
  final List<UserModel> employees;

  HomeAdmState({
    required this.status,
    required this.employees,
  });

  HomeAdmState copyWith({
    HomeAmdStateStatus? status,
    List<UserModel>? employees,
  }) {
    return HomeAdmState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
    );
  }
}
