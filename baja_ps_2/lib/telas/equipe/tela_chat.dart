import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/histórico_chat.dart';
import '../../modelos/modelo_chat.dart';

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