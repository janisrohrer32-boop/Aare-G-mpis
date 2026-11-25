import 'package:flutter/material.dart';

import '../components/woman_painter.dart';
import '../models/character.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// Vorschau der Figur (für Menü und Shop).
class FigurePreview extends StatelessWidget {
  const FigurePreview({
    super.key,
    required this.character,
    required this.outfit,
    this.style = 3,
    this.pose = Pose.stand,
    this.height = 160,
  });

  final CharacterDef character;
  final OutfitDef outfit;
  final int style;
  final Pose pose;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.6,
      height: height,
      child: CustomPaint(painter: _FigurePainter(character, outfit, style, pose)),
    );
  }
}

class _FigurePainter extends CustomPainter {
  _FigurePainter(this.character, this.outfit, this.style, this.pose);
  final CharacterDef character;
  final OutfitDef outfit;
  final int style;
  final Pose pose;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 76;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    WomanPainter.paint(canvas,
        pose: pose, character: character, outfit: outfit, style: style, grounded: true, groundY: 36);
  }

  @override
  bool shouldRepaint(_FigurePainter old) =>
      old.character != character || old.outfit != outfit || old.style != style || old.pose != pose;
}

/// Münzanzeige.
class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key, required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 20),
        const SizedBox(width: 6),
        Text('$coins',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
    );
  }
}

/// Style-Level als Sterne.
class StyleStars extends StatelessWidget {
  const StyleStars({super.key, required this.style, this.size = 22});
  final int style;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < 5; i++)
        Icon(i < style ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFFFD54F), size: size),
    ]);
  }
}

String styleLabel(int s) => switch (s) {
      0 => 'Total ramponiert',
      1 => 'Zerzaust',
      2 => 'Etwas mitgenommen',
      3 => 'Normal',
      4 => 'Strahlend',
      _ => 'Superstar',
    };

/// Ton an/aus.
class MuteButton extends StatelessWidget {
  const MuteButton({super.key, required this.storage, required this.audio});
  final StorageService storage;
  final AudioService audio;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: audio,
      builder: (_, _) => IconButton.filledTonal(
        tooltip: audio.muted ? 'Ton an' : 'Ton aus',
        onPressed: () {
          audio.toggleMute();
          storage.muted = audio.muted;
        },
        icon: Icon(audio.muted ? Icons.volume_off : Icons.volume_up),
      ),
    );
  }
}
