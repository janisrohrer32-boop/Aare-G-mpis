import 'package:flutter/material.dart';

import '../models/cliff_level.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    const level = CliffLevel.bergsee;
    final best = widget.storage.highscore(level.id);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF0277BD)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌊', style: TextStyle(fontSize: 72)),
                const Text(
                  'CLIFF DIVE',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [Shadow(offset: Offset(3, 3), blurRadius: 4, color: Colors.black38)],
                  ),
                ),
                const SizedBox(height: 8),
                Text('${level.name} · ${level.heightMeters.toStringAsFixed(0)} m',
                    style: const TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 4),
                Text('Highscore: $best',
                    style: const TextStyle(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 40),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => GameScreen(level: level, storage: widget.storage),
                    ));
                    setState(() {}); // Highscore aktualisieren
                  },
                  child: const Text('SPIELEN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
