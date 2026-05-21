import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/histórico_chat.dart';
import 'providers/mensagem_piloto.dart';
import 'cadastro.dart';
import 'modelos/modelo_chat.dart';
import 'telas/login/tela_login.dart';
import 'telas/alternador.dart';

void main() {
  runApp(const BajaApp());
}

class BajaApp extends StatelessWidget {
  const BajaApp({super.key});

  @override
  Widget build(BuildContext context) {
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BajaChat>(create: (_) => BajaChat()),
        ChangeNotifierProvider<BajaPilot>(create: (_) => BajaPilot()),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Baja Communication',
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