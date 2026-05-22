import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/histórico_chat.dart';
import '../../modelos/modelo_chat.dart';
import 'package:flutter/services.dart';
import '../mapa.dart';

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
          MapOverlay(
            minimized: _mapMinimized,
            onToggle: () => setState(() => _mapMinimized = !_mapMinimized),
          ),
        ],
      ),
    );
  }
}