import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'main.dart';

enum UserProfile { pilot, team }

//Classe de config de tema e navegação do login
class BajaApp extends StatelessWidget {
  const BajaApp({super.key});

  @override
  Widget build(BuildContext context) {

    //Config do tema do app
    final colorScheme = ColorScheme.dark(
      primary: Colors.pink.shade400,
      onPrimary: Colors.white,
      secondary: Colors.green.shade700,
      onSecondary: Colors.white,
      error: Colors.red.shade700,
      onError: Colors.white,
      surfaceContainerHighest: Colors.grey.shade900,
      surface: Colors.grey.shade800,
      onSurface: Colors.white,
      primaryContainer: Colors.blueGrey.shade700,
      onPrimaryContainer: Colors.white,
      outline: Colors.white30,
      outlineVariant: Colors.white54,
    );

    return ChangeNotifierProvider<BajaChat>(
      create: (_) => BajaChat(),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Baja Communication',

          //Config da aplicação do tema no nosso app
          theme: ThemeData(

            useMaterial3: true,
            colorScheme: colorScheme,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: colorScheme.surfaceContainerHighest,
            
            appBarTheme: AppBarTheme(
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              titleTextStyle: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            inputDecorationTheme: InputDecorationTheme(
              fillColor: colorScheme.surfaceContainerHighest,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),

          ),

          //Mudança de tela de login para piloto ou equipe
          home: Consumer<BajaChat>(
            builder: (context, chat, _) {
              if (!chat.isLoggedIn) return const LoginScreen();
              if (chat.profile == UserProfile.pilot) return const RootScreen(initialIndex: 1);
              return const RootScreen(initialIndex: 0);
            },
          ),

        );
      },
    );
  }
}

//Classe de atributos da mensagem
class ChatMessage {
  final String id;
  final String content;
  final bool fromPilot;
  final String? originalMessageId;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.fromPilot,
    this.originalMessageId,
    required this.timestamp,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  String get senderLabel => fromPilot ? 'Piloto' : 'Equipe';
  
}

//Classe de funcionamento da mensagem
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

  List<String> _options = [
    "BOX!",
    "FREIO!",
    "ELÉTRICA!",
    "COMBUSTÍVEL!",
    "POWERTRAIN!",
    "PROTEÇÃO CVT",
    "NÃO ENTENDI",
    "OK",
    "NEGATIVO",
  ];

  List<String> get options => _options;

  void sendMessage({
    required String content,
    required bool fromPilot,
    String? originalMessageId,
  }) {
    if (content.trim().isEmpty) return;
    _messages.add(ChatMessage(
      content: content,
      fromPilot: fromPilot,
      originalMessageId: originalMessageId,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void updateOptions(List<String> newOptions) {
    _options = List<String>.from(newOptions);
    notifyListeners();
  }
}