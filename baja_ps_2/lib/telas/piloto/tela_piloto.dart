import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/histórico_chat.dart';
import '../../providers/mensagem_piloto.dart';
import '../../modelos/modelo_chat.dart';
import '../equipe/tela_chat.dart';
import '../mapa.dart';

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

    if (widget.message.priority == MessagePriority.localizacao) {
      _gpsTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
        if (!mounted) return;
        setState(() {
          _gpsTick++;
          if (_gpsTick >= 4) {
            _gpsReady = true;
            _gpsTimer?.cancel();
          } else {
            _lat = _baseLat + (_gpsTick * 0.00015);
            _lng = _baseLng - (_gpsTick * 0.0001);
          }
        });
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _gpsTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(String char) {
    final chat = Provider.of<BajaChat>(context, listen: false);
    final p = widget.pilotOptions.firstWhere(
      (o) => o.label.toLowerCase().startsWith(char.toLowerCase()),
      orElse: () => widget.pilotOptions.first,
    );
    chat.sendMessage(content: p.message, fromPilot: true);
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.message.priority;
    final isBlinkingPriority = p == MessagePriority.urgente || p == MessagePriority.box;
    final bg = isBlinkingPriority
        ? (_visible ? p.color : Colors.black)
        : p.color;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        final txt = event.character;
        if (txt != null && txt.isNotEmpty) {
          setState(() => _highlightedKey = txt.toLowerCase());
          _handleKey(txt);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    '⚠ ${p.label.toUpperCase()} — EQUIPE',
                    style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: p == MessagePriority.localizacao
                        ? _buildGpsContent()
                        : Text(
                            widget.message.content.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isBlinkingPriority ? Colors.white : p.onColor,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildHorizontalKeyboard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGpsContent() {
    if (!_gpsReady) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 5)),
          const SizedBox(height: 24),
          Text(
            'CONECTANDO GPS...\n[TICK $_gpsTick/4]',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white, width: 4)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset('assets/images/Mapa_Baja.jpeg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            Positioned(
              top: 100,
              left: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  ),
                  const Icon(Icons.navigation, color: Colors.white, size: 20),
                ],
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  'LAT: ${_lat.toStringAsFixed(5)}  |  LNG: ${_lng.toStringAsFixed(5)}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalKeyboard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.pilotOptions.map((opt) {
          final char = opt.label[0].toLowerCase();
          final isSel = _highlightedKey == char;
          final oc = opt.optionColor;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 64,
              decoration: BoxDecoration(
                color: isSel ? Colors.white : oc.bg,
                borderRadius: BorderRadius.circular(8),
                border: isSel ? Border.all(color: oc.selectedBorder, width: 4) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    opt.label[0].toUpperCase(),
                    style: TextStyle(color: isSel ? Colors.black : oc.fg, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    opt.label.substring(1).toUpperCase(),
                    style: TextStyle(color: isSel ? Colors.black87 : oc.fg.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
  bool _mapMinimized = true;

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<BajaChat>(context);
    final pilotData = Provider.of<BajaPilot>(context);
    final list = chat.messages;
    final lastTeamMessage = list.isEmpty ? null : list.lastWhere((m) => !m.fromPilot, orElse: () => list.first);

    return Theme(
      data: _buildPilotTheme(context),
      child: Builder(
        builder: (ctx) {
          if (lastTeamMessage != null && lastTeamMessage.timestamp.add(const Duration(seconds: 12)).isAfter(DateTime.now())) {
            return FullscreenTeamBanner(
              message: lastTeamMessage,
              pilotOptions: pilotData.options,
              onDismiss: () => setState(() {}),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('PAINEL DO PILOTO')),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final msg = list[i];
                          return ChatMessageCard(
                            message: msg,
                            colorScheme: Theme.of(context).colorScheme,
                            textTheme: Theme.of(context).textTheme,
                            pilotView: true,
                          );
                        },
                      ),
                    ),
                    _buildPilotKeyboard(ctx, chat, pilotData.options),
                  ],
                ),
                MapOverlay(
                  minimized: _mapMinimized,
                  onToggle: () => setState(() => _mapMinimized = !_mapMinimized),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPilotKeyboard(BuildContext ctx, BajaChat chat, List<PilotOption> options) {
    return Container(
      color: Theme.of(ctx).colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
        children: options.map((opt) {
          final oc = opt.optionColor;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: oc.bg,
              foregroundColor: oc.fg,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => chat.sendMessage(content: opt.message, fromPilot: true),
            child: Text(
              opt.label.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
            ),
          );
        }).toList(),
      ),
    );
  }

  ThemeData _buildPilotTheme(BuildContext context) {
    final base = ThemeData.dark();
    final cs = ColorScheme.fromSeed(seedColor: Colors.pink, brightness: Brightness.dark);
    return base.copyWith(
      colorScheme: cs,
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outline)),
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
}