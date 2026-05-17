import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BajaApp());
}

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
      case MessagePriority.info:    return const Duration(milliseconds: 900);
      case MessagePriority.atencao: return const Duration(milliseconds: 600);
      case MessagePriority.urgente: return const Duration(milliseconds: 380);
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
    ),
  ];

  void cadastrar(String nome, String email, String senha, String perfil) {
    _usuarios.add(User(nome: nome, email: email, senha: senha, perfil: perfil));
  }

  User? login(String email, String senha) {
    for (final u in _usuarios) {
      if (u.email == email && u.senha == senha) return u;
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

class BajaPilot extends ChangeNotifier {
  final List<String> _options = [
    "Freio",
    "Elétrica",
    "Powertrain",
    "Combustivel",
    "Proteção CVT",
    "Não",
    "Sim",
    "Não Entendi",
  ];

  List<String> get options => _options;
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

class PriorityBadge extends StatelessWidget {
  final MessagePriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 12, color: priority.onColor),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: priority.onColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessageCard extends StatelessWidget {
  final ChatMessage message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const ChatMessageCard({
    super.key,
    required this.message,
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
              if (!message.fromPilot) ...[
                PriorityBadge(priority: message.priority),
                const SizedBox(height: 6),
              ],
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
  MessagePriority _priority = MessagePriority.info;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    Provider.of<BajaChat>(context, listen: false).sendMessage(
      content: _controller.text,
      fromPilot: false,
      priority: _priority,
    );
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
            onPressed: () => Provider.of<BajaChat>(context, listen: false).logout(),
          ),
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
                    final message = chatData.messages[chatData.messages.length - 1 - index];
                    return ChatMessageCard(
                      message: message,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: MessagePriority.values.map((p) {
                    final selected = _priority == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? p.color
                                : p.color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: selected
                                  ? p.color
                                  : p.color.withValues(alpha: 0.4),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(p.icon,
                                  size: 14,
                                  color: selected ? p.onColor : p.color),
                              const SizedBox(width: 4),
                              Text(
                                p.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? p.onColor : p.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Mensagem para o piloto...",
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlinkingTeamBanner extends StatefulWidget {
  const BlinkingTeamBanner({super.key});

  @override
  State<BlinkingTeamBanner> createState() => _BlinkingTeamBannerState();
}

class _BlinkingTeamBannerState extends State<BlinkingTeamBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  MessagePriority _curPriority = MessagePriority.info;
  String? _dismissedId;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: MessagePriority.info.blinkDuration,
    );
    _applyAnims(MessagePriority.info);
  }

  void _applyAnims(MessagePriority p) {
    _fade = Tween(begin: 1.0, end: p.blinkMinOpacity).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _scale = Tween(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  void _syncAnim(bool active, MessagePriority p) {
    if (active) {
      if (_curPriority != p) {
        _curPriority = p;
        _ctrl.stop();
        _ctrl.duration = p.blinkDuration;
        _applyAnims(p);
      }
      if (!_ctrl.isAnimating) _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  void _dismiss(String msgId) {
    _dismissTimer?.cancel();
    context.read<BajaChat>().sendMessage(content: "Entendi", fromPilot: true);
    setState(() => _dismissedId = msgId);
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _dismissedId = null);
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<BajaChat>(
      builder: (context, chat, _) {
        if (chat.messages.isEmpty) return const SizedBox.shrink();

        final teamMsgs = chat.messages.where((m) => !m.fromPilot).toList();
        if (teamMsgs.isEmpty) return const SizedBox.shrink();

        final latest = teamMsgs.last;
        final latestIdx = chat.messages.lastIndexWhere((m) => !m.fromPilot);
        final pilotReplied =
            chat.messages.skip(latestIdx + 1).any((m) => m.fromPilot);

        if (pilotReplied || _dismissedId == latest.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _syncAnim(false, latest.priority);
          });
          return const SizedBox.shrink();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _syncAnim(true, latest.priority);
        });

        final h = latest.timestamp.hour.toString().padLeft(2, '0');
        final m = latest.timestamp.minute.toString().padLeft(2, '0');
        final p = latest.priority;

        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _scale.value,
            child: Opacity(
              opacity: _fade.value,
              child: Container(
                width: double.infinity,
                color: p.color,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(p.icon, color: p.onColor, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "⚠ ATENÇÃO — EQUIPE",
                                style: textTheme.labelSmall?.copyWith(
                                  color: p.onColor.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              PriorityBadge(priority: p),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            latest.content,
                            style: textTheme.titleMedium?.copyWith(
                              color: p.onColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$h:$m",
                            style: textTheme.labelSmall?.copyWith(
                              color: p.onColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _dismiss(latest.id),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        "ENTENDI",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.onColor,
                        foregroundColor: p.color,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PilotActionButtons extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String> onConfirm;

  const PilotActionButtons({
    super.key,
    required this.options,
    required this.onConfirm,
  });

  @override
  State<PilotActionButtons> createState() => _PilotActionButtonsState();
}

class _PilotActionButtonsState extends State<PilotActionButtons> {
  int _selected = 0;
  bool _confirmed = false;
  Timer? _confirmTimer;

  @override
  void didUpdateWidget(covariant PilotActionButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selected >= widget.options.length) _selected = 0;
  }

  @override
  void dispose() {
    _confirmTimer?.cancel();
    super.dispose();
  }

  void _up() {
    if (_selected > 0) setState(() => _selected--);
  }

  void _down() {
    if (_selected < widget.options.length - 1) setState(() => _selected++);
  }

  void _confirm() {
    widget.onConfirm(widget.options[_selected]);
    setState(() {
      _confirmed = true;
      _selected = 0;
    });
    _confirmTimer?.cancel();
    _confirmTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _confirmed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (widget.options.isEmpty) {
      return const Center(child: Text("Nenhuma opção disponível"));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Escolha uma ação:",
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            tooltip: "Subir",
            onPressed: _selected > 0 ? _up : null,
          ),
        ),
        for (int i = 0; i < widget.options.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ElevatedButton(
              onPressed: () => setState(() => _selected = i),
              style: ElevatedButton.styleFrom(
                backgroundColor: i == _selected
                    ? colorScheme.primary
                    : colorScheme.primaryContainer,
                foregroundColor: i == _selected
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.centerLeft,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  widget.options[i],
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        Center(
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: "Descer",
            onPressed: _selected < widget.options.length - 1 ? _down : null,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _confirmed
              ? ElevatedButton.icon(
                  key: const ValueKey('confirmed'),
                  onPressed: null,
                  icon: const Icon(Icons.check_circle, size: 22),
                  label: const Text(
                    "ENVIADO!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.green.shade600,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                )
              : ElevatedButton(
                  key: const ValueKey('idle'),
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "CONFIRMAR",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
        ),
      ],
    );
  }
}

class PilotScreen extends StatelessWidget {
  const PilotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("BAJA - Piloto"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Trocar perfil',
            onPressed: () =>
                Provider.of<BajaChat>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          const BlinkingTeamBanner(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Consumer<BajaChat>(
                      builder: (context, chat, _) {
                        if (chat.messages.isEmpty) {
                          return Center(
                            child: Text(
                              "Nenhuma mensagem ainda.",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: chat.messages.length,
                          itemBuilder: (context, i) {
                            final msg =
                                chat.messages[chat.messages.length - 1 - i];
                            return Container(
                              decoration: !msg.fromPilot
                                  ? BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: msg.priority.color,
                                          width: 4,
                                        ),
                                      ),
                                    )
                                  : null,
                              child: ChatMessageCard(
                                message: msg,
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: colorScheme.surface,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      child: Consumer<BajaPilot>(
                        builder: (context, piloto, _) {
                          return PilotActionButtons(
                            options: piloto.options,
                            onConfirm: (opt) =>
                                context.read<BajaChat>().sendMessage(
                                      content: opt,
                                      fromPilot: true,
                                    ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  static const List<Widget> _screens = [
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