import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/histórico_chat.dart';
import '../../providers/mensagem_piloto.dart';
import '../../modelos/modelo_chat.dart';
import '../equipe/tela_chat.dart';

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
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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