import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/histórico_chat.dart';
import '../../providers/mensagem_piloto.dart';
import '../../modelos/modelo_chat.dart';
import '../equipe/tela_chat.dart';

import '../mapa.dart';


enum _BannerMode { normal, parado, localizacao }

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
                        '⚠ ${p.label.toUpperCase()} — EQUIPE',
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

class PilotActionButtons extends StatefulWidget {
  final List<PilotOption> options;
  final ValueChanged<PilotOption> onConfirm;
  final bool enabled;
  const PilotActionButtons({super.key, required this.options, required this.onConfirm, required this.enabled});

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
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    }
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
      autofocus: widget.enabled,
      canRequestFocus: widget.enabled,
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
                              enabled: pending == null,
                              onConfirm: (opt) => chat.sendMessage(content: opt.message, fromPilot: true),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  MapOverlay(
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