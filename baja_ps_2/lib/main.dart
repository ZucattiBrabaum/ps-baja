import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/historico_chat.dart';
import 'providers/mensagem_piloto.dart';
import 'cadastro.dart';
import 'modelos/modelo_chat.dart';
import 'telas/login/tela_login.dart';
import 'telas/alternador.dart';


void main() => runApp(const BajaApp());

class BajaApp extends StatelessWidget {
  const BajaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = ColorScheme.dark(
      primary:                  Colors.pink.shade400,
      onPrimary:                Colors.white,
      secondary:                Colors.green.shade700,
      onSecondary:              Colors.white,
      error:                    Colors.red.shade700,
      onError:                  Colors.white,
      surfaceContainerHighest:  Colors.grey.shade900,
      surface:                  Colors.grey.shade800,
      onSurface:                Colors.white,
      primaryContainer:         Colors.blueGrey.shade700,
      onPrimaryContainer:       Colors.white,
      outline:                  Colors.white30,
      outlineVariant:           Colors.white54,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BajaChat()),
        ChangeNotifierProvider(create: (_) => BajaPilot()),
        Provider(create: (_) => AuthService()),
      ],
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Baja Communication',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: cs,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: cs.surfaceContainerHighest,
          appBarTheme: AppBarTheme(
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
            titleTextStyle: TextStyle(
              color: cs.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            fillColor: cs.surfaceContainerHighest,
            filled: true,
            border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.primary)),
          ),
        ),
        home: Consumer<BajaChat>(
          builder: (_, chat, _) {
            if (!chat.isLoggedIn) return const LoginScreen();
            return RootScreen(initialIndex: chat.profile == UserProfile.pilot ? 1 : 0);
          },
        ),
      ),
    );
  }
}