import 'package:flutter/material.dart';
import '../modelos/modelo_chat.dart';

class BajaPilot extends ChangeNotifier {
  final options = const [
    PilotOption(label: 'Freio',        message: 'Problema no sistema de freio', optionColor: PilotOptionColor.freio),
    PilotOption(label: 'Elétrica',     message: 'Problema na parte elétrica',   optionColor: PilotOptionColor.eletrica),
    PilotOption(label: 'Powertrain',   message: 'Problema no powertrain',        optionColor: PilotOptionColor.powertrain),
    PilotOption(label: 'Combustível',  message: 'Preciso de combustível',        optionColor: PilotOptionColor.combustivel),
    PilotOption(label: 'Proteção CVT', message: 'Problema na proteção do CVT',   optionColor: PilotOptionColor.cvt),
    PilotOption(label: 'Não',          message: 'Não',                           optionColor: PilotOptionColor.nao),
    PilotOption(label: 'Sim',          message: 'Sim',                           optionColor: PilotOptionColor.sim),
    PilotOption(label: 'Não Entendi',  message: 'Não entendi a mensagem',        optionColor: PilotOptionColor.naoEntendi),
  ];
}