import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../cadastro.dart';
import '../../providers/histórico_chat.dart';
import '../../modelos/modelo_chat.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String _perfilSelecionado = "equipe";

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
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nome"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: "Senha"),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _perfilSelecionado,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "equipe", child: Text("Equipe")),
                DropdownMenuItem(value: "piloto", child: Text("Piloto")),
              ],
              onChanged: (valor) => setState(() => _perfilSelecionado = valor!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Preencha o nome")),
                  );
                  return;
                }    
                if (_emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Preencha o email")),
                  );
                  return;
                }                
                if (!_emailController.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Insira um email válido")),
                  );
                  return;
                }            
                if (_senhaController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Senha deve ter pelo menos 6 caracteres")),
                  );
                  return;
                }
                final auth = Provider.of<AuthService>(context, listen: false);
                final chat = Provider.of<BajaChat>(context, listen: false);

                auth.cadastrar(
                  _nameController.text,
                  _emailController.text,
                  _senhaController.text,
                  _perfilSelecionado,
                );

                final perfil = _perfilSelecionado == "piloto"
                    ? UserProfile.pilot
                    : UserProfile.team;
                Navigator.pop(context);
                chat.selectProfile(perfil);
              },
              child: const Text("Cadastrar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Já possui uma conta? Entre"),
            ),
          ],
        ),
      ),
    );
  }
}