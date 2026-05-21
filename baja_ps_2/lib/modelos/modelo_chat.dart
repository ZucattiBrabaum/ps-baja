import 'package:flutter/material.dart';

enum MessagePriority { info, atencao, urgente }

extension MessagePriorityExt on MessagePriority {
  String get label {
    switch (this) {
      case MessagePriority.info:    return 'Info';
      case MessagePriority.atencao: return 'Atenção';
      case MessagePriority.urgente: return 'Urgente';
    }
  }

  IconData get icon {
    switch (this) {
      case MessagePriority.info:    return Icons.info_outline;
      case MessagePriority.atencao: return Icons.warning_amber_rounded;
      case MessagePriority.urgente: return Icons.warning_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MessagePriority.info:    return const Color(0xFF1565C0);
      case MessagePriority.atencao: return const Color(0xFFF9A825);
      case MessagePriority.urgente: return const Color(0xFFCC0000);
    }
  }

  Color get onColor {
    switch (this) {
      case MessagePriority.info:    return Colors.white;
      case MessagePriority.atencao: return Colors.black87;
      case MessagePriority.urgente: return Colors.white;
    }
  }

  Duration get blinkDuration {
    switch (this) {
      case MessagePriority.info:    return const Duration(milliseconds: 0);
      case MessagePriority.atencao: return const Duration(milliseconds: 0);
      case MessagePriority.urgente: return const Duration(milliseconds: 0);
    }
  }

  double get blinkMinOpacity {
    switch (this) {
      case MessagePriority.info:    return 0.45;
      case MessagePriority.atencao: return 0.30;
      case MessagePriority.urgente: return 0.15;
    }
  }
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
}