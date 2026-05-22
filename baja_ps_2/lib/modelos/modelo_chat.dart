import 'package:flutter/material.dart';

const kMsgLocalizacao = 'Onde você está?';
const kMsgParado = 'O carro está parado?';


enum MessagePriority {info, atencao, urgente, box, localizacao, parado}

extension MessagePriorityExt on MessagePriority {
  String get label => switch (this) {
    MessagePriority.info        => 'Info',
    MessagePriority.atencao     => 'Atenção',
    MessagePriority.urgente     => 'Urgente',
    MessagePriority.box         => 'BOX',
    MessagePriority.localizacao => 'Localização',
    MessagePriority.parado      => 'Parado?',
  };

  IconData get icon => switch (this) {
    MessagePriority.info        => Icons.info_outline,
    MessagePriority.atencao     => Icons.warning_amber_rounded,
    MessagePriority.urgente     => Icons.warning_rounded,
    MessagePriority.box         => Icons.garage_outlined,
    MessagePriority.localizacao => Icons.location_on_outlined,
    MessagePriority.parado      => Icons.directions_car_outlined,
  };

  Color get color => switch (this) {
    MessagePriority.info        => const Color(0xFF1565C0),
    MessagePriority.atencao     => const Color(0xFFF9A825),
    MessagePriority.urgente     => const Color(0xFFCC0000),
    MessagePriority.box         => const Color(0xFF6A1B9A),
    MessagePriority.localizacao => const Color(0xFF00695C),
    MessagePriority.parado      => const Color(0xFFE65100),
  };

  Color get onColor => this == MessagePriority.atencao ? Colors.black87 : Colors.white;

  // Copiado exatamente das regras de tempo do mainnovo.dart
  Duration get blinkDuration => switch (this) {
    MessagePriority.urgente => const Duration(milliseconds: 400),
    MessagePriority.box     => const Duration(milliseconds: 600),
    _                       => const Duration(seconds: 2),
  };
}

enum PilotOptionColor { freio, eletrica, powertrain, combustivel, cvt, nao, sim, naoEntendi }

extension PilotOptionColorExt on PilotOptionColor {
  Color get bg => switch (this) {
    PilotOptionColor.freio       => const Color(0xFFB71C1C),
    PilotOptionColor.eletrica    => const Color(0xFF1565C0),
    PilotOptionColor.powertrain  => const Color(0xFF4A148C),
    PilotOptionColor.combustivel => const Color(0xFFE65100),
    PilotOptionColor.cvt         => const Color(0xFF004D40),
    PilotOptionColor.nao         => const Color(0xFF37474F),
    PilotOptionColor.sim         => const Color(0xFF1B5E20),
    PilotOptionColor.naoEntendi  => const Color(0xFF880E4F),
  };

  Color get fg => Colors.white;

  Color get selectedBorder => switch (this) {
    PilotOptionColor.freio       => const Color(0xFFEF9A9A),
    PilotOptionColor.eletrica    => const Color(0xFF90CAF9),
    PilotOptionColor.powertrain  => const Color(0xFFCE93D8),
    PilotOptionColor.combustivel => const Color(0xFFFFCC80),
    PilotOptionColor.cvt         => const Color(0xFF80CBC4),
    PilotOptionColor.nao         => const Color(0xFFB0BEC5),
    PilotOptionColor.sim         => const Color(0xFFA5D6A7),
    PilotOptionColor.naoEntendi  => const Color(0xFFF48FB1),
  };
}

enum UserProfile { pilot, team }

class ChatMessage {
  final String id;
  final String content;
  final bool fromPilot;
  final DateTime timestamp;
  final MessagePriority priority;

  ChatMessage({
    required this.content,
    required this.fromPilot,
    required this.timestamp,
    this.priority = MessagePriority.info,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  String get senderLabel => fromPilot ? 'Piloto' : 'Equipe';
  bool get isLocalizacao  => content.trim() == kMsgLocalizacao;
  bool get isParado       => content.trim() == kMsgParado;
}

class PilotOption {
  final String label;
  final String message;
  final PilotOptionColor optionColor;
  const PilotOption({required this.label, required this.message, required this.optionColor});
}