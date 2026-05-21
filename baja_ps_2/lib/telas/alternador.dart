import 'package:flutter/material.dart';
import 'equipe/tela_chat.dart';
import 'piloto/tela_piloto.dart';

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