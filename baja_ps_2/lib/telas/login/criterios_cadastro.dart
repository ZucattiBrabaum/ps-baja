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
  final _nomeCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  String _perfil = 'equipe';

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Baja Communication'),
            const SizedBox(height: 32),
            TextField(controller: _nomeCtrl,  decoration: const InputDecoration(labelText: 'Nome')),
            const SizedBox(height: 16),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(controller: _senhaCtrl, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _perfil,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'equipe', child: Text('Equipe')),
                DropdownMenuItem(value: 'piloto', child: Text('Piloto')),
              ],
              onChanged: (v) => setState(() => _perfil = v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_nomeCtrl.text.isEmpty)         { _snack('Preencha o nome'); return; }
                if (_emailCtrl.text.isEmpty)        { _snack('Preencha o email'); return; }
                if (!_emailCtrl.text.contains('@')) { _snack('Email inválido'); return; }
                if (_senhaCtrl.text.length < 6)     { _snack('Senha deve ter pelo menos 6 caracteres'); return; }
                context.read<AuthService>().cadastrar(_nomeCtrl.text, _emailCtrl.text, _senhaCtrl.text, _perfil);
                Navigator.pop(context);
                context.read<BajaChat>().selectProfile(_perfil == 'piloto' ? UserProfile.pilot : UserProfile.team);
              },
              child: const Text('Cadastrar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Já possui uma conta? Entre'),
            ),
          ],
        ),
      ),
    );
  }
}