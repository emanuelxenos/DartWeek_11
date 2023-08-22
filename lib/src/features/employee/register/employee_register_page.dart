import 'dart:developer';

import 'package:dw_barbershop/src/core/providers/application_providers.dart';
import 'package:dw_barbershop/src/core/ui/helpers/messages.dart';
import 'package:dw_barbershop/src/core/ui/widgets/avatar_widget.dart';
import 'package:dw_barbershop/src/core/ui/widgets/barbershop_loader.dart';
import 'package:dw_barbershop/src/core/ui/widgets/hours_panel.dart';
import 'package:dw_barbershop/src/core/ui/widgets/weekdays_panel.dart';
import 'package:dw_barbershop/src/features/employee/register/employee_register_state.dart';
import 'package:dw_barbershop/src/features/employee/register/employee_register_vm.dart';
import 'package:dw_barbershop/src/model/barbershop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';

class EmployeeRegisterPage extends ConsumerStatefulWidget {
  const EmployeeRegisterPage({super.key});

  @override
  ConsumerState<EmployeeRegisterPage> createState() =>
      _EmployeeRegisterPageState();
}

class _EmployeeRegisterPageState extends ConsumerState<EmployeeRegisterPage> {
  var resgisterADM = false;

  final formKey = GlobalKey<FormState>();
  final nameEC = TextEditingController();
  final emailEC = TextEditingController();
  final passwordEC = TextEditingController();

  @override
  void dispose() {
    nameEC.dispose();
    emailEC.dispose();
    passwordEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeRegisterVm = ref.watch(employeeRegisterVmProvider.notifier);
    final barbershopAsyncValue = ref.watch(getMyBarberShopProvider);

    ref.listen(employeeRegisterVmProvider.select((state) => state.status),
        (_, status) {
      switch (status) {
        case EmployeeRegisterStateStatus.initial:
          break;
        case EmployeeRegisterStateStatus.success:
          Messages.showSuccess('Colaborador cadastrado com sucesso', context);
          Navigator.of(context).pop();
        case EmployeeRegisterStateStatus.error:
          Messages.showError('Erro ao registrar colaborador', context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Coloaborador'),
      ),
      body: barbershopAsyncValue.when(
          data: (barbershopModel) {
            final BarbershopModel(:openingDays, :openingHours) =
                barbershopModel;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: formKey,
                  child: Center(
                    child: Column(
                      children: [
                        const AvatarWidget(),
                        const SizedBox(
                          height: 32,
                        ),
                        Row(
                          children: [
                            Checkbox.adaptive(
                              value: resgisterADM,
                              onChanged: (value) {
                                setState(() {
                                  resgisterADM = !resgisterADM;
                                  employeeRegisterVm
                                      .setRegisterADM(resgisterADM);
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Sou administrador e quero me cadastrar como colaborador',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        Offstage(
                          offstage: resgisterADM,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 24,
                              ),
                              TextFormField(
                                controller: nameEC,
                                validator: resgisterADM
                                    ? null
                                    : Validatorless.required(
                                        'Nome obrigatóiro'),
                                decoration:
                                    const InputDecoration(label: Text('Nome')),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              TextFormField(
                                controller: emailEC,
                                validator: resgisterADM
                                    ? null
                                    : Validatorless.multiple([
                                        Validatorless.required(
                                            'Email obrigtório'),
                                        Validatorless.email(
                                            'Insira email Válido'),
                                      ]),
                                decoration: const InputDecoration(
                                    label: Text('E-mail')),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              TextFormField(
                                obscureText: true,
                                validator: resgisterADM
                                    ? null
                                    : Validatorless.multiple([
                                        Validatorless.required(
                                            'Senha obrigtóri'),
                                        Validatorless.min(
                                            6, 'deve conter 6 caracteres'),
                                      ]),
                                decoration:
                                    const InputDecoration(label: Text('Senha')),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        WeekdaysPanel(
                          enabledDays: openingDays,
                          onDayPressed: employeeRegisterVm.addOrRemoveWorkdays,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        HoursPanel(
                          startTime: 6,
                          endTime: 23,
                          onHourPressed:
                              employeeRegisterVm.addOrRemoveWorkHours,
                          enabledTimes: openingHours,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56)),
                            onPressed: () {
                              switch (formKey.currentState?.validate()) {
                                case null || false:
                                  Messages.showError(
                                      'Existe campos invalidos', context);
                                case true:
                                  final EmployeeRegisterState(
                                    workdays: List(isNotEmpty: hasworkDays),
                                    workhours: List(isNotEmpty: hasworkHours),
                                  ) = ref.watch(employeeRegisterVmProvider);
                                  if (!hasworkDays || !hasworkHours) {
                                    Messages.showError(
                                        'Por favor selecione os dias da semana e horario de atendimento',
                                        context);
                                    return;
                                  }

                                  final name = nameEC.text;
                                  final password = passwordEC.text;
                                  final email = emailEC.text;

                                  employeeRegisterVm.register(
                                    name: name,
                                    password: password,
                                    email: email,
                                  );
                              }
                            },
                            child: const Text('Cadastrar Coloborador'))
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            log('Erro ao buscar a página',
                error: error, stackTrace: stackTrace);
            return const Center(
              child: Text('Erro ao carregar página'),
            );
          },
          loading: () => const BarbershopLoader()),
    );
  }
}
