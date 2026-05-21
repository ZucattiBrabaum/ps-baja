import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cadastro.dart';
import '../../providers/histórico_chat.dart';
import '../../modelos/modelo_chat.dart';
import 'criterios_cadastro.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Baja Communication"),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Preencha o email")),
                  );
                  return;
                }
                if (_senhaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Preencha a senha")),
                  );
                  return;
                }  
                final auth = Provider.of<AuthService>(context, listen: false);
                final chat = Provider.of<BajaChat>(context, listen: false);
                final usuario = auth.login(_emailController.text, _senhaController.text);

                if (usuario != null) {
                  final perfil = usuario.perfil == "piloto"
                      ? UserProfile.pilot
                      : UserProfile.team;
                  chat.selectProfile(perfil);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Email ou senha incorretos")),
                  );
                }
              },
              child: const Text("Entrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("Não tem conta? Cadastre-se"),
            ),
          ],
        ),
      ),
    );
  }
}