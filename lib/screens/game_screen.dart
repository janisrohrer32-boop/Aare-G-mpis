import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/cliff_dive_game.dart';
import '../models/cliff_level.dart';
import '../models/landing.dart';
import '../services/storage_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level, required this.storage});
  final CliffLevel level;
  final StorageService storage;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CliffDiveGame game =
      CliffDiveGame(level: widget.level, storage: widget.storage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => game.input.pointerDown(e.localPosition),
        onPointerMove: (e) => game.input.pointerMove(e.localPosition),
        onPointerUp: (e) => game.input.pointerUp(e.localPosition),
        child: GameWidget(
          game: game,
          overlayBuilderMap: {
            'hud': (context, CliffDiveGame g) => _Hud(game: g),
            'result': (context, CliffDiveGame g) => _ResultPanel(game: g),
          },
          initialActiveOverlays: const ['hud'],
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.game});
  final CliffDiveGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                ValueListenableBuilder<int>(
                  valueListenable: game.liveScore,
                  builder: (_, v, _) => _Pill(text: '$v Punkte'),
                ),
              ],
            ),
            const Spacer(),
            ValueListenableBuilder<String>(
              valueListenable: game.hint,
              builder: (_, v, _) => v.isEmpty
                  ? const SizedBox.shrink()
                  : _Pill(text: v, small: true),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.small = false});
  final String text;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: small ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 14 : 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.game});
  final CliffDiveGame game;

  @override
  Widget build(BuildContext context) {
    final r = game.lastResult;
    if (r == null) return const SizedBox.shrink();
    final color = switch (r.landing.quality) {
      LandingQuality.perfect => Colors.green,
      LandingQuality.good => Colors.blue,
      LandingQuality.bellyFlop => Colors.red,
    };
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(blurRadius: 20, color: Colors.black26)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(r.landing.label,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 12),
            if (r.tricks.isEmpty)
              const Text('Keine Tricks – versuch mal zu wischen!')
            else
              for (final t in r.tricks)
                Row(children: [Text(t.name), const Spacer(), Text('+${t.basePoints}')]),
            const Divider(height: 24),
            Row(children: [
              const Text('Landung'),
              const Spacer(),
              Text('x${r.landing.multiplier}  +${r.landing.bonus}'),
            ]),
            const SizedBox(height: 8),
            Text('${r.total} Punkte',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            Text(r.newHighscore ? '🏆 Neuer Highscore!' : 'Highscore: ${r.highscore}'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: game.reset,
              icon: const Icon(Icons.replay),
              label: const Text('Nochmal springen'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
