import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'classes.dart';
void main() {
  runApp(const BajaApp());
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chat = Provider.of<BajaChat>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.directions_car, size: 72, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'BAJA Communication', 
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione seu perfil para continuar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 48),
              _ProfileCard(
                icon: Icons.people_alt,
                label: 'Equipe',
                description: 'Acesso ao chat e gerenciamento',
                color: colorScheme.primary,
                onTap: () => chat.selectProfile(UserProfile.team),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                icon: Icons.drive_eta,
                label: 'Piloto',
                description: 'Acesso rápido aos botões de status',
                color: colorScheme.secondary,
                onTap: () => chat.selectProfile(UserProfile.pilot),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            ],
          ),
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