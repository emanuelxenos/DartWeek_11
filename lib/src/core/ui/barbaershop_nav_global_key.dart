import 'package:flutter/material.dart';

class BarbaershopNavGlobalKey {
  static BarbaershopNavGlobalKey? _instance;

  final navKey = GlobalKey<NavigatorState>();

  BarbaershopNavGlobalKey._();

  static BarbaershopNavGlobalKey get instance =>
      _instance ??= BarbaershopNavGlobalKey._();
}
