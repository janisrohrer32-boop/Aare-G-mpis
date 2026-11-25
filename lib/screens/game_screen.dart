import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/cliff_dive_game.dart';
import '../models/landing.dart';
import '../models/level.dart';
import '../models/trick.dart';
import '../services/storage_service.dart';
import 'widgets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level, required this.storage});
  final JumpLevel level;
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
      LandingQuality.perfect => Colors.green.shade700,
      LandingQuality.good => Colors.blueGrey.shade700,
      LandingQuality.crash => Colors.red.shade700,
    };
    final counts = <Trick, int>{};
    for (final t in r.tricks) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
    final styleText = r.styleAfter > r.styleBefore
        ? 'Sie strahlt noch mehr!'
        : r.styleAfter < r.styleBefore
            ? 'Das hat Spuren hinterlassen...'
            : styleLabel(r.styleAfter);
    return Center(
      child: Container(
        width: 330,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [BoxShadow(blurRadius: 24, color: Colors.black38)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(r.landing.label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 10),
            if (r.tricks.isEmpty)
              const Text('Keine Saltos. Wisch in der Luft nach oben oder unten!',
                  textAlign: TextAlign.center)
            else
              for (final e in counts.entries)
                Row(children: [
                  Text('${e.value}x ${e.key.name}'),
                  const Spacer(),
                  Text('+${e.value * e.key.basePoints}'),
                ]),
            const Divider(height: 22),
            Row(children: [
              const Text('Landung'),
              const Spacer(),
              Text('x${r.landing.multiplier}  +${r.landing.bonus}'),
            ]),
            const SizedBox(height: 8),
            Text('${r.total} Punkte',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            Text(r.newHighscore ? 'Neuer Highscore!' : 'Highscore: ${r.highscore}'),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
              const SizedBox(width: 4),
              Text('+${r.coins} Münzen', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            StyleStars(style: r.styleAfter),
            Text(styleText, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: game.reset,
              icon: const Icon(Icons.replay),
              label: const Text('Nochmal springen'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Zum Menü'),
            ),
          ],
        ),
      ),
    );
  }
}
