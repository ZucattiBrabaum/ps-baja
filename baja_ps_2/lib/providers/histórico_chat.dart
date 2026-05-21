import 'package:flutter/material.dart';
import '../modelos/modelo_chat.dart';

class BajaChat extends ChangeNotifier {
  UserProfile? _profile;
  UserProfile? get profile => _profile;
  bool get isLoggedIn => _profile != null;

  void selectProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void logout() {
    _profile = null;
    notifyListeners();
  }

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  void sendMessage({
    required String content,
    required bool fromPilot,
    MessagePriority priority = MessagePriority.info,
  }) {
    if (content.trim().isEmpty) return;
    _messages.add(ChatMessage(
      content: content,
      fromPilot: fromPilot,
      timestamp: DateTime.now(),
      priority: priority,
    ));
    notifyListeners();
  }
}