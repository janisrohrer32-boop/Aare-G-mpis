import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';
import 'shop_screen.dart';
import 'widgets.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.storage, required this.audio});
  final StorageService storage;
  final AudioService audio;

  @override
  Widget build(BuildContext context) {
    const level = JumpLevel.tower;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F3E6B), Color(0xFF7F9DBF), Color(0xFFF0C9A0)],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([storage, audio]),
            builder: (context, _) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    MuteButton(storage: storage, audio: audio),
                    const Spacer(),
                    CoinBadge(coins: storage.coins),
                  ]),
                ),
                const Spacer(),
                const Text(
                  'CLIFF DIVE',
                  style: TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 3,
                    shadows: [Shadow(offset: Offset(2, 3), blurRadius: 6, color: Colors.black38)],
                  ),
                ),
                const Text('Endlos-Sprung vom Hochhaus',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 16),
                FigurePreview(
                    character: storage.character,
                    outfit: storage.outfit,
                    style: 3,
                    height: 200),
                const SizedBox(height: 12),
                Text('Bester Lauf: ${storage.highscore(level.id)} Punkte',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                Text(
                    storage.bestFloor(level.id) == 0
                        ? 'Start im ${level.startFloor}. Stock'
                        : 'Höchster Sprung: ${storage.bestFloor(level.id)}. Stock',
                    style: const TextStyle(fontSize: 15, color: Colors.white70)),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    audio.startMusic();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => GameScreen(level: level, storage: storage, audio: audio),
                    ));
                  },
                  child: const Text('SPRINGEN'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    audio.startMusic();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ShopScreen(storage: storage, audio: audio),
                    ));
                  },
                  icon: const Icon(Icons.storefront),
                  label: const Text('SHOP', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
