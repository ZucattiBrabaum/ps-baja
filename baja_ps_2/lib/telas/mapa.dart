import 'package:flutter/material.dart';

class MapOverlay extends StatelessWidget {
  final bool minimized;
  final VoidCallback onToggle;

  const MapOverlay({super.key, required this.minimized, required this.onToggle});

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