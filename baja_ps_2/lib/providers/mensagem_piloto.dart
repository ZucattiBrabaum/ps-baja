import 'package:flutter/material.dart';

class BajaPilot extends ChangeNotifier {
  final List<String> _options = [
    "Freio",
    "Elétrica",
    "Powertrain",
    "Combustivel",
    "Proteção CVT",
    "Não",
    "Sim",
    "Não Entendi",
  ];

  List<String> get options => _options;
}