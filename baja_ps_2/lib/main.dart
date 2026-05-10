
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BajaApp());
}

enum UserProfile { pilot, team }

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

class User {
  String nome;
  String email;
  String senha;
  String perfil;

  User({
    required this.nome,
    required this.email,
    required this.senha,
    required this.perfil,
  });
}

class AuthService {
  final List<User> _usuarios = [
    User(
      nome: "Teste",
      email: "vitorteste@baja.com",
      senha: "ronaldo",
      perfil: "piloto",
    )
  ];

  void cadastrar(String nome, String email, String senha, String perfil) {
    User novoUsuario = User(
      nome: nome,
      email: email,
      senha: senha,
      perfil: perfil,
    );
    _usuarios.add(novoUsuario);
  }

  User? login(String email, String senha) {
    for (User u in _usuarios) {
      if (u.email == email && u.senha == senha) {
        return u;
      }
    }
    return null;
  }        
}            

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
    "PNEU OK",
    "MOTOR OK",
    "PROBLEMA NA TRACAO",
    "SUPER AQUECIMENTO!",
    "PROBLEMA COM FREIO!",
    "PROBLEMA NA SUSPENSAO",
    "PROBLEMA ELETRICO",
    "FALHA NA DIRECAO",
    "COMBUSTIVEL BAIXO",
    "MENSAGEM LIVRE",
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
      body: 
      Padding (
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Baja Communication"),
            SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: "Senha",
                          ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final auth = Provider.of<AuthService>(context, listen: false);
                final chat = Provider.of<BajaChat>(context, listen: false);

                final usuario = auth.login(
                  _emailController.text,
                  _senhaController.text,
                );

                if (usuario != null) {
                  final perfil = usuario.perfil == "piloto"
                    ? UserProfile.pilot
                    : UserProfile.team;
                  chat.selectProfile (perfil);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar (content: Text("Email ou senha incorretos")),
                  );
                }
              },
              child: Text("Entrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text("Não tem conta? Cadastre-se"),
            ),
          ],
        ),
      ),
    );
  }
}

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
      body: 
      Padding (
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Baja Communication"),
            SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nome",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: "Senha",
                          ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _perfilSelecionado,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: "equipe", child: Text("Equipe")),
                DropdownMenuItem(value: "piloto", child: Text("Piloto")),
              ],
              onChanged: (valor) {
                setState(() {
                  _perfilSelecionado = valor!;
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
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
              child: Text("Cadastrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Já possui uma conta? Entre")
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessageCard extends StatelessWidget {
  final ChatMessage message;
  final String? repliedContent;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const ChatMessageCard({
    super.key,
    required this.message,
    this.repliedContent,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final timeString =
        "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: message.fromPilot ? Alignment.centerLeft : Alignment.centerRight,
      child: Card(
        color: message.fromPilot
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (repliedContent != null)
                Text(
                  "Respondendo a: $repliedContent",
                  style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              Text(
                "${message.senderLabel}: ${message.content}",
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(timeString, style: textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    Provider.of<BajaChat>(context, listen: false)
        .sendMessage(content: _controller.text, fromPilot: false);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("BAJA - Equipe"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Trocar perfil',
            onPressed: () =>
                Provider.of<BajaChat>(context, listen: false).logout(),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Consumer<BajaChat>(
              builder: (context, chatData, _) {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: chatData.messages.length,
                  itemBuilder: (context, index) {
                    final ChatMessage message = chatData
                        .messages[chatData.messages.length - 1 - index];
                    String? repliedContent;
                    if (message.originalMessageId != null) {
                      for (var msg in chatData.messages) {
                        if (msg.id == message.originalMessageId) {
                          repliedContent = msg.content;
                          break;
                        }
                      }
                    }
                    return ChatMessageCard(
                      message: message,
                      repliedContent: repliedContent,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Mensagem para o piloto...",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (String _) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  tooltip: "Enviar",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PilotActionButtons extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onOptionSelected;

  const PilotActionButtons({
    super.key,
    required this.options,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (options.isEmpty) {
      return const Center(child: Text("Nenhuma opção disponível"));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Escolha uma ação:",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (BuildContext _, BoxConstraints constraints) {
            double buttonWidth = (constraints.maxWidth - 8) / 2;
            if (buttonWidth < 150) buttonWidth = constraints.maxWidth;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: options.map<Widget>((String option) {
                return SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: () => onOptionSelected(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(option, textAlign: TextAlign.center),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class PilotScreen extends StatelessWidget {
  const PilotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bajaChat = Provider.of<BajaChat>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("BAJA - Piloto"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Trocar perfil',
            onPressed: () =>
                Provider.of<BajaChat>(context, listen: false).logout(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: PilotActionButtons(
                    options: bajaChat.options,
                    onOptionSelected: (option) => bajaChat.sendMessage(
                      content: option,
                      fromPilot: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  final int initialIndex;
  const RootScreen({super.key, this.initialIndex = 0});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    ChatScreen(),
    PilotScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Equipe'),
          BottomNavigationBarItem(icon: Icon(Icons.drive_eta), label: 'Piloto'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surface,
        onTap: (int i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
