import 'package:flutter/material.dart';

void main() {
  runApp(const BajaApp());
}

class BajaApp extends StatelessWidget {
  const BajaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Baja Communication',
      theme: ThemeData(
        primarySwatch: Colors.red, // Vermelho Baja
        useMaterial3: true,
      ),
      home: const ComunicacaoScreen(),
    );
  }
}

class ComunicacaoScreen extends StatefulWidget {
  const ComunicacaoScreen({super.key});

  @override
  State<ComunicacaoScreen> createState() => _ComunicacaoScreenState();
}

class _ComunicacaoScreenState extends State<ComunicacaoScreen> {
  // Lista para simular o banco de mensagens
  final List<String> _mensagens = [];
  final TextEditingController _controller = TextEditingController();

  void _enviarMensagem(String texto) {
    if (texto.isEmpty) return;
    setState(() {
      _mensagens.add(texto);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BAJA - Piloto")),
      body: Column(
        children: [
          // Área das mensagens
          Expanded(
            child: ListView.builder(
              itemCount: _mensagens.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.message),
                title: Text(_mensagens[index]),
              ),
            ),
          ),
          
          // Área de botões rápidos (Onde entra a lógica das "Roots")
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 10,
              children: [
                ElevatedButton(onPressed: () => _enviarMensagem("BOX NOW!"), child: const Text("BOX")),
                ElevatedButton(onPressed: () => _enviarMensagem("PNEU ok"), child: const Text("PNEU")),
              ],
            ),
          ),

          // Área de input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Mensagem..."))),
                IconButton(icon: const Icon(Icons.send), onPressed: () => _enviarMensagem(_controller.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
