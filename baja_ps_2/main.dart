import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() => runApp(const BajaApp());

const kMsgLocalizacao = 'Onde você está?';
const kMsgParado = 'O carro está parado?';

enum MessagePriority { info, atencao, urgente, box, localizacao, parado }

extension MessagePriorityExt on MessagePriority {
  String get label => switch (this) {
    MessagePriority.info        => 'Info',
    MessagePriority.atencao     => 'Atenção',
    MessagePriority.urgente     => 'Urgente',
    MessagePriority.box         => 'BOX',
    MessagePriority.localizacao => 'Localização',
    MessagePriority.parado      => 'Parado?',
  };

  IconData get icon => switch (this) {
    MessagePriority.info        => Icons.info_outline,
    MessagePriority.atencao     => Icons.warning_amber_rounded,
    MessagePriority.urgente     => Icons.warning_rounded,
    MessagePriority.box         => Icons.garage_outlined,
    MessagePriority.localizacao => Icons.location_on_outlined,
    MessagePriority.parado      => Icons.directions_car_outlined,
  };

  Color get color => switch (this) {
    MessagePriority.info        => const Color(0xFF1565C0),
    MessagePriority.atencao     => const Color(0xFFF9A825),
    MessagePriority.urgente     => const Color(0xFFCC0000),
    MessagePriority.box         => const Color(0xFF6A1B9A),
    MessagePriority.localizacao => const Color(0xFF00695C),
    MessagePriority.parado      => const Color(0xFFE65100),
  };

  Color get onColor => this == MessagePriority.atencao ? Colors.black87 : Colors.white;

  Duration get blinkDuration => switch (this) {
    MessagePriority.info        => const Duration(milliseconds: 900),
    MessagePriority.atencao     => const Duration(milliseconds: 600),
    MessagePriority.urgente     => const Duration(milliseconds: 300),
    MessagePriority.box         => const Duration(milliseconds: 450),
    MessagePriority.localizacao => const Duration(milliseconds: 700),
    MessagePriority.parado      => const Duration(milliseconds: 550),
  };

  String get bannerLabel => switch (this) {
    MessagePriority.box         => '🏁 BOX — EQUIPE',
    MessagePriority.localizacao => '📍 LOCALIZAÇÃO — EQUIPE',
    MessagePriority.parado      => '🚗 SITUAÇÃO — EQUIPE',
    _                           => '⚠ ATENÇÃO — EQUIPE',
  };
}

enum PilotOptionColor { freio, eletrica, powertrain, combustivel, cvt, nao, sim, naoEntendi }

extension PilotOptionColorExt on PilotOptionColor {
  Color get bg => switch (this) {
    PilotOptionColor.freio       => const Color(0xFFB71C1C),
    PilotOptionColor.eletrica    => const Color(0xFF1565C0),
    PilotOptionColor.powertrain  => const Color(0xFF4A148C),
    PilotOptionColor.combustivel => const Color(0xFFE65100),
    PilotOptionColor.cvt         => const Color(0xFF004D40),
    PilotOptionColor.nao         => const Color(0xFF37474F),
    PilotOptionColor.sim         => const Color(0xFF1B5E20),
    PilotOptionColor.naoEntendi  => const Color(0xFF880E4F),
  };

  Color get fg => Colors.white;

  Color get selectedBorder => switch (this) {
    PilotOptionColor.freio       => const Color(0xFFEF9A9A),
    PilotOptionColor.eletrica    => const Color(0xFF90CAF9),
    PilotOptionColor.powertrain  => const Color(0xFFCE93D8),
    PilotOptionColor.combustivel => const Color(0xFFFFCC80),
    PilotOptionColor.cvt         => const Color(0xFF80CBC4),
    PilotOptionColor.nao         => const Color(0xFFB0BEC5),
    PilotOptionColor.sim         => const Color(0xFFA5D6A7),
    PilotOptionColor.naoEntendi  => const Color(0xFFF48FB1),
  };
}

enum UserProfile { pilot, team }

enum _BannerMode { normal, parado, localizacao }

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
  bool get isLocalizacao  => content.trim() == kMsgLocalizacao;
  bool get isParado       => content.trim() == kMsgParado;
}

class PilotOption {
  final String label;
  final String message;
  final PilotOptionColor optionColor;
  const PilotOption({required this.label, required this.message, required this.optionColor});
}

class User {
  final String nome, email, senha, perfil;
  User({required this.nome, required this.email, required this.senha, required this.perfil});
}

class AuthService {
  final List<User> _usuarios = [
    User(nome: 'Teste', email: 'vitorteste@baja.com', senha: 'ronaldo', perfil: 'piloto'),
  ];

  void cadastrar(String nome, String email, String senha, String perfil) =>
      _usuarios.add(User(nome: nome, email: email, senha: senha, perfil: perfil));

  User? login(String email, String senha) {
    try {
      return _usuarios.firstWhere((u) => u.email == email && u.senha == senha);
    } catch (_) {
      return null;
    }
  }
}

class BajaChat extends ChangeNotifier {
  UserProfile? _profile;
  final List<ChatMessage> _messages = [];

  UserProfile? get profile     => _profile;
  bool get isLoggedIn          => _profile != null;
  List<ChatMessage> get messages => _messages;

  void selectProfile(UserProfile p) { _profile = p; notifyListeners(); }
  void logout()                     { _profile = null; notifyListeners(); }

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
  final options = const [
    PilotOption(label: 'Freio',        message: 'Problema no sistema de freio', optionColor: PilotOptionColor.freio),
    PilotOption(label: 'Elétrica',     message: 'Problema na parte elétrica',   optionColor: PilotOptionColor.eletrica),
    PilotOption(label: 'Powertrain',   message: 'Problema no powertrain',        optionColor: PilotOptionColor.powertrain),
    PilotOption(label: 'Combustível',  message: 'Preciso de combustível',        optionColor: PilotOptionColor.combustivel),
    PilotOption(label: 'Proteção CVT', message: 'Problema na proteção do CVT',   optionColor: PilotOptionColor.cvt),
    PilotOption(label: 'Não',          message: 'Não',                           optionColor: PilotOptionColor.nao),
    PilotOption(label: 'Sim',          message: 'Sim',                           optionColor: PilotOptionColor.sim),
    PilotOption(label: 'Não Entendi',  message: 'Não entendi a mensagem',        optionColor: PilotOptionColor.naoEntendi),
  ];
}

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

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
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            TextField(controller: _senhaCtrl, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_emailCtrl.text.isEmpty) { _snack('Preencha o email'); return; }
                if (_senhaCtrl.text.isEmpty) { _snack('Preencha a senha'); return; }
                final u = context.read<AuthService>().login(_emailCtrl.text, _senhaCtrl.text);
                if (u != null) {
                  context.read<BajaChat>().selectProfile(u.perfil == 'piloto' ? UserProfile.pilot : UserProfile.team);
                } else {
                  _snack('Email ou senha incorretos');
                }
              },
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Não tem conta? Cadastre-se'),
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
  final bool pilotView;

  const ChatMessageCard({
    super.key,
    required this.message,
    required this.colorScheme,
    required this.textTheme,
    this.pilotView = false,
  });

  @override
  Widget build(BuildContext context) {
    final time = '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';
    final fromTeam = !message.fromPilot;

    final cardColor = (fromTeam && pilotView)
        ? Colors.green.shade700
        : message.fromPilot
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer;

    final textColor = (fromTeam && pilotView) ? Colors.white : null;

    return Align(
      alignment: message.fromPilot ? Alignment.centerLeft : Alignment.centerRight,
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fromTeam) ...[
                PriorityBadge(priority: message.priority),
                const SizedBox(height: 6),
              ],
              Text(
                '${message.senderLabel}: ${message.content}',
                style: textTheme.bodyLarge?.copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: textTheme.labelSmall?.copyWith(color: textColor?.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final MessagePriority priority;
  final VoidCallback onTap;

  const _QuickButton({required this.label, required this.priority, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = priority.color;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 1.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(priority.icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.2,
                ),
              ),
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
  final _controller  = TextEditingController();
  final _focusNode   = FocusNode();
  MessagePriority _priority = MessagePriority.info;
  bool _mapMinimized = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
         event.logicalKey == LogicalKeyboardKey.shiftRight)) {
      setState(() => _mapMinimized = !_mapMinimized);
    }
    return false;
  }

  void _send() {
    if (_controller.text.isEmpty) return;
    context.read<BajaChat>().sendMessage(
      content: _controller.text,
      fromPilot: false,
      priority: _priority,
    );
    _controller.clear();
  }

  void _sendQuick(String msg, MessagePriority p) =>
      context.read<BajaChat>().sendMessage(content: msg, fromPilot: false, priority: p);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BAJA - Equipe'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<BajaChat>().logout(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer<BajaChat>(
                  builder: (_, chat, _) => ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(top: 236, left: 8, right: 8, bottom: 8),
                    itemCount: chat.messages.length,
                    itemBuilder: (_, i) {
                      final msg = chat.messages[chat.messages.length - 1 - i];
                      return ChatMessageCard(message: msg, colorScheme: cs, textTheme: tt);
                    },
                  ),
                ),
              ),
              Container(
                color: cs.surface,
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _QuickButton(
                          label: 'BOX!!',
                          priority: MessagePriority.box,
                          onTap: () => _sendQuick('BOX!!', MessagePriority.box),
                        ),
                        const SizedBox(width: 6),
                        _QuickButton(
                          label: 'Onde você está?',
                          priority: MessagePriority.localizacao,
                          onTap: () => _sendQuick(kMsgLocalizacao, MessagePriority.localizacao),
                        ),
                        const SizedBox(width: 6),
                        _QuickButton(
                          label: 'O carro está parado?',
                          priority: MessagePriority.parado,
                          onTap: () => _sendQuick(kMsgParado, MessagePriority.parado),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [MessagePriority.info, MessagePriority.atencao, MessagePriority.urgente].map((p) {
                        final sel = _priority == p;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _priority = p),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: sel ? p.color : p.color.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: sel ? p.color : p.color.withValues(alpha: 0.4),
                                  width: sel ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(p.icon, size: 14, color: sel ? p.onColor : p.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    p.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: sel ? p.onColor : p.color,
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
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            decoration: const InputDecoration(
                              hintText: 'Mensagem para o piloto...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.send), onPressed: _send),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          _MapOverlay(
            minimized: _mapMinimized,
            onToggle: () => setState(() => _mapMinimized = !_mapMinimized),
          ),
        ],
      ),
    );
  }
}

class _MapOverlay extends StatelessWidget {
  final bool minimized;
  final VoidCallback onToggle;

  const _MapOverlay({required this.minimized, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(2, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: minimized ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild:  Image.asset('assets/images/Mapa_Baja.jpeg', height: 220, fit: BoxFit.fitHeight),
                  secondChild: Image.asset('assets/images/Mapa_Baja.jpeg', height: 48, width: 72, fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      minimized ? Icons.expand_more : Icons.expand_less,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FullscreenTeamBanner extends StatefulWidget {
  final ChatMessage message;
  final List<PilotOption> pilotOptions;
  final VoidCallback onDismiss;

  const FullscreenTeamBanner({
    super.key,
    required this.message,
    required this.pilotOptions,
    required this.onDismiss,
  });

  @override
  State<FullscreenTeamBanner> createState() => _FullscreenTeamBannerState();
}

class _FullscreenTeamBannerState extends State<FullscreenTeamBanner> {
  final _focusNode = FocusNode();

  bool _visible = true;
  Timer? _blinkTimer;

  String? _highlightedKey;

  static const _baseLat = -25.4284;
  static const _baseLng = -49.2733;
  double _lat = _baseLat;
  double _lng = _baseLng;
  bool _gpsReady = false;
  Timer? _gpsTimer;
  int _gpsTick = 0;

  @override
  void initState() {
    super.initState();
    _blinkTimer = Timer.periodic(widget.message.priority.blinkDuration, (_) {
      if (mounted) setState(() => _visible = !_visible);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    if (widget.message.isLocalizacao) _startGps();
  }

  void _startGps() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _gpsReady = true);
      _gpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        _gpsTick++;
        setState(() {
          _lat = _baseLat + ((_gpsTick * 7919) % 5 - 2) * 0.00002;
          _lng = _baseLng + ((_gpsTick * 6271) % 5 - 2) * 0.00002;
        });
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _gpsTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  _BannerMode get _mode {
    if (widget.message.isParado)      return _BannerMode.parado;
    if (widget.message.isLocalizacao) return _BannerMode.localizacao;
    return _BannerMode.normal;
  }

  String get _gpsString => 'GPS: ${_lat.toStringAsFixed(4)} / ${_lng.toStringAsFixed(4)}';

  void _reply(String content) {
    context.read<BajaChat>().sendMessage(content: content, fromPilot: true);
    widget.onDismiss();
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;

    switch (_mode) {
      case _BannerMode.normal:
        if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
          _reply('Entendi');
          return KeyEventResult.handled;
        }

      case _BannerMode.parado:
        if (key == LogicalKeyboardKey.arrowUp) {
          setState(() => _highlightedKey = 'up');
          Future.delayed(const Duration(milliseconds: 150), () { if (mounted) _reply('Sim'); });
          return KeyEventResult.handled;
        }
        if (key == LogicalKeyboardKey.arrowDown) {
          setState(() => _highlightedKey = 'down');
          Future.delayed(const Duration(milliseconds: 150), () { if (mounted) _reply('Não'); });
          return KeyEventResult.handled;
        }

      case _BannerMode.localizacao:
        if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
          if (_gpsReady) _reply(_gpsString);
          return KeyEventResult.handled;
        }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.message.priority;
    final h = widget.message.timestamp.hour.toString().padLeft(2, '0');
    final m = widget.message.timestamp.minute.toString().padLeft(2, '0');

    if (!_visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (_, e) => _handleKey(e),
        child: Container(
          color: p.color,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(p.icon, color: p.onColor, size: 40),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.bannerLabel,
                        style: TextStyle(
                          color: p.onColor.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '$h:$m',
                        style: TextStyle(color: p.onColor.withValues(alpha: 0.65), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.message.content,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.onColor, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              if (_mode == _BannerMode.normal)      _buildNormal(p),
              if (_mode == _BannerMode.parado)      _buildParado(p),
              if (_mode == _BannerMode.localizacao) _buildLocalizacao(p),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormal(MessagePriority p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_return, color: p.onColor.withValues(alpha: 0.7), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Pressione Enter para confirmar',
                  style: TextStyle(color: p.onColor.withValues(alpha: 0.7), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _reply('Entendi'),
          icon: const Icon(Icons.check, size: 20),
          label: const Text('ENTENDI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          style: ElevatedButton.styleFrom(
            backgroundColor: p.onColor,
            foregroundColor: p.color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildParado(MessagePriority p) {
    final simHL = _highlightedKey == 'up';
    final naoHL = _highlightedKey == 'down';

    Widget btn(String label, IconData icon, bool highlighted, VoidCallback onTap) => Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: highlighted ? Colors.white : p.onColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.onColor, width: highlighted ? 3 : 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: highlighted ? p.color : p.onColor, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: highlighted ? p.color : p.onColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_upward,   color: p.onColor.withValues(alpha: 0.7), size: 16),
                Text(' SIM    ', style: TextStyle(color: p.onColor.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_downward, color: p.onColor.withValues(alpha: 0.7), size: 16),
                Text(' NÃO',    style: TextStyle(color: p.onColor.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            btn('SIM', Icons.arrow_upward,   simHL, () => _reply('Sim')),
            const SizedBox(width: 12),
            btn('NÃO', Icons.arrow_downward, naoHL, () => _reply('Não')),
          ],
        ),
      ],
    );
  }

  Widget _buildLocalizacao(MessagePriority p) {
    final dimColor = p.onColor.withValues(alpha: _gpsReady ? 0.7 : 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: p.onColor.withValues(alpha: _gpsReady ? 0.6 : 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _gpsReady ? Icons.gps_fixed : Icons.gps_not_fixed,
                    color: _gpsReady ? p.onColor : p.onColor.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _gpsReady ? 'SINAL OK' : 'BUSCANDO SINAL...',
                    style: TextStyle(
                      color: _gpsReady ? p.onColor : p.onColor.withValues(alpha: 0.4),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_gpsReady) ...[
                _CoordRow(label: 'LAT', value: _lat.toStringAsFixed(4), color: p.onColor),
                const SizedBox(height: 8),
                _CoordRow(label: 'LNG', value: _lng.toStringAsFixed(4), color: p.onColor),
              ] else
                Text(
                  '--- / ---',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: p.onColor.withValues(alpha: 0.3),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_return, color: dimColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  _gpsReady ? 'Enter para enviar localização' : 'Aguarde o sinal GPS...',
                  style: TextStyle(color: dimColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _gpsReady ? () => _reply(_gpsString) : null,
          icon: Icon(_gpsReady ? Icons.send : Icons.hourglass_empty, size: 20),
          label: Text(
            _gpsReady ? 'ENVIAR LOCALIZAÇÃO' : 'AGUARDANDO GPS...',
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:         _gpsReady ? p.onColor : p.onColor.withValues(alpha: 0.2),
            foregroundColor:         _gpsReady ? p.color   : p.onColor.withValues(alpha: 0.4),
            disabledBackgroundColor: p.onColor.withValues(alpha: 0.2),
            disabledForegroundColor: p.onColor.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class _CoordRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _CoordRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class PilotScreen extends StatefulWidget {
  const PilotScreen({super.key});
  @override
  State<PilotScreen> createState() => _PilotScreenState();
}

class _PilotScreenState extends State<PilotScreen> {
  String? _dismissedMsgId;
  bool _mapMinimized = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
         event.logicalKey == LogicalKeyboardKey.shiftRight)) {
      setState(() => _mapMinimized = !_mapMinimized);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _pilotTheme(),
      child: Builder(builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final tt = Theme.of(context).textTheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('BAJA - Piloto'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => context.read<BajaChat>().logout(),
              ),
            ],
          ),
          body: Consumer2<BajaChat, BajaPilot>(
            builder: (context, chat, piloto, _) {
              ChatMessage? pending;
              if (chat.messages.isNotEmpty) {
                final teamMsgs = chat.messages.where((m) => !m.fromPilot).toList();
                if (teamMsgs.isNotEmpty) {
                  final latest    = teamMsgs.last;
                  final latestIdx = chat.messages.lastIndexWhere((m) => !m.fromPilot);
                  final replied   = chat.messages.skip(latestIdx + 1).any((m) => m.fromPilot);
                  if (!replied && _dismissedMsgId != latest.id) pending = latest;
                }
              }

              return Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            border: Border(right: BorderSide(color: cs.outline)),
                          ),
                          child: chat.messages.isEmpty
                              ? Center(
                                  child: Text(
                                    'Nenhuma mensagem ainda.',
                                    style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)),
                                  ),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  padding: const EdgeInsets.only(top: 236, left: 8, right: 8, bottom: 8),
                                  itemCount: chat.messages.length,
                                  itemBuilder: (_, i) {
                                    final msg = chat.messages[chat.messages.length - 1 - i];
                                    return Container(
                                      decoration: !msg.fromPilot
                                          ? BoxDecoration(
                                              border: Border(
                                                left: BorderSide(color: msg.priority.color, width: 4),
                                              ),
                                            )
                                          : null,
                                      child: ChatMessageCard(
                                        message: msg,
                                        colorScheme: cs,
                                        textTheme: tt,
                                        pilotView: true,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                          color: cs.surface,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                            child: PilotActionButtons(
                              options: piloto.options,
                              onConfirm: (opt) => chat.sendMessage(content: opt.message, fromPilot: true),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _MapOverlay(
                    minimized: _mapMinimized,
                    onToggle: () => setState(() => _mapMinimized = !_mapMinimized),
                  ),
                  if (pending != null)
                    FullscreenTeamBanner(
                      key: ValueKey(pending.id),
                      message: pending,
                      pilotOptions: piloto.options,
                      onDismiss: () => setState(() => _dismissedMsgId = pending?.id),
                    ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}

ThemeData _pilotTheme() {
  final cs = ColorScheme.light(
    primary:                  Colors.pink.shade600,
    onPrimary:                Colors.white,
    secondary:                Colors.green.shade700,
    onSecondary:              Colors.white,
    error:                    Colors.red.shade700,
    onError:                  Colors.white,
    surfaceContainerHighest:  Colors.grey.shade100,
    surface:                  Colors.white,
    onSurface:                Colors.grey.shade900,
    primaryContainer:         Colors.pink.shade100,
    onPrimaryContainer:       Colors.grey.shade900,
    outline:                  Colors.grey.shade400,
    outlineVariant:           Colors.grey.shade600,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    brightness: Brightness.light,
    scaffoldBackgroundColor: cs.surfaceContainerHighest,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.pink.shade600,
      foregroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black26,
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(color: Colors.white),
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
      fillColor: Colors.white,
      filled: true,
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outline)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outline)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.primary)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    iconTheme: IconThemeData(color: Colors.grey.shade800),
    dividerColor: Colors.grey.shade300,
  );
}

class PilotActionButtons extends StatefulWidget {
  final List<PilotOption> options;
  final ValueChanged<PilotOption> onConfirm;
  const PilotActionButtons({super.key, required this.options, required this.onConfirm});

  @override
  State<PilotActionButtons> createState() => _PilotActionButtonsState();
}

class _PilotActionButtonsState extends State<PilotActionButtons> {
  int _selected = 0;
  bool _confirmed = false;
  Timer? _confirmTimer;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void didUpdateWidget(covariant PilotActionButtons old) {
    super.didUpdateWidget(old);
    if (_selected >= widget.options.length) _selected = 0;
  }

  @override
  void dispose() {
    _confirmTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _up()   { if (_selected > 0)                         setState(() => _selected--); }
  void _down() { if (_selected < widget.options.length - 1) setState(() => _selected++); }

  void _confirm() {
    widget.onConfirm(widget.options[_selected]);
    setState(() { _confirmed = true; _selected = 0; });
    _confirmTimer?.cancel();
    _confirmTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _confirmed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (widget.options.isEmpty) return const Center(child: Text('Nenhuma opção disponível'));

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.arrowUp)                                                   { _up();      return KeyEventResult.handled; }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown)                                                 { _down();    return KeyEventResult.handled; }
        if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) { _confirm(); return KeyEventResult.handled; }
        return KeyEventResult.ignored;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Escolha uma ação:',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          const SizedBox(height: 4),
          Center(
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_up),
              onPressed: _selected > 0 ? _up : null,
            ),
          ),
          for (int i = 0; i < widget.options.length; i++)
            Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: _buildOption(i)),
          Center(
            child: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
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
                    label: const Text('ENVIADO!', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:         Colors.green.shade600,
                      foregroundColor:         Colors.white,
                      disabledBackgroundColor: Colors.green.shade600,
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  )
                : ElevatedButton(
                    key: const ValueKey('idle'),
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.secondary,
                      foregroundColor: cs.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CONFIRMAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int i) {
    final opt = widget.options[i];
    final oc  = opt.optionColor;
    final sel = i == _selected;

    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: sel ? oc.bg : oc.bg.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: sel ? oc.selectedBorder : oc.bg.withValues(alpha: 0.5),
            width: sel ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            if (sel)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.chevron_right, size: 18, color: oc.fg),
              ),
            Text(
              opt.label,
              style: TextStyle(
                color: sel ? oc.fg : oc.bg,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
  late int _index;

  @override
  void initState() { super.initState(); _index = widget.initialIndex; }

  static const _screens = [ChatScreen(), PilotScreen()];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor:   cs.primary,
        unselectedItemColor: cs.onSurface,
        backgroundColor:     cs.surface,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Equipe'),
          BottomNavigationBarItem(icon: Icon(Icons.drive_eta),  label: 'Piloto'),
        ],
      ),
    );
  }
}