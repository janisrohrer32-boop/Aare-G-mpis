import 'package:flutter/painting.dart';

enum HairStyle { ponytail, long, bob, bun, short, buzz, spiky, none }

enum BottomStyle { leggings, shorts, skirt, pants }

enum BodyType { female, male }

enum Species { human, cat, dog, panda }

/// Eine spielbare Figur.
class CharacterDef {
  const CharacterDef({
    required this.id,
    required this.name,
    required this.price,
    required this.skin,
    required this.hair,
    required this.hairStyle,
    this.body = BodyType.female,
    this.species = Species.human,
    this.headColor,
    this.lips,
    this.eyes = const Color(0xFF4E342E),
    this.beard,
  });

  final String id;
  final String name;
  final int price;

  /// Haut bzw. Fell an Armen und Beinen.
  final Color skin;
  final Color hair;
  final HairStyle hairStyle;
  final BodyType body;
  final Species species;

  /// Kopffarbe, falls anders als [skin] (z. B. Panda).
  final Color? headColor;
  final Color? lips;
  final Color eyes;
  final Color? beard;

  bool get isAnimal => species != Species.human;

  /// Welche Stimme bei Landungen spricht.
  String get voice => isAnimal ? 'a' : (body == BodyType.male ? 'm' : 'f');

  String get group => isAnimal ? 'Tiere' : (body == BodyType.male ? 'Männer' : 'Frauen');
}

/// Ein Outfit aus dem Shop.
class OutfitDef {
  const OutfitDef({
    required this.id,
    required this.name,
    required this.price,
    required this.top,
    required this.bottom,
    required this.bottomStyle,
    required this.shoes,
    this.longSleeves = false,
    this.cropTop = false,
    this.cape,
    this.mask,
    this.belt,
    this.accent,
    this.dots,
  });

  final String id;
  final String name;
  final int price;
  final Color top;
  final Color bottom;
  final BottomStyle bottomStyle;
  final Color shoes;
  final bool longSleeves;
  final bool cropTop;
  final Color? cape;
  final Color? mask;
  final Color? belt;

  /// Zweitfarbe, z. B. Streifen oder Reissverschluss.
  final Color? accent;

  /// Muster (Punkte/Blumen) auf dem Oberteil.
  final Color? dots;
}

/// Ein Soundtrack, der im Shop freigeschaltet werden kann.
class MusicTrack {
  const MusicTrack({required this.id, required this.name, required this.info, required this.price});
  final String id;
  final String name;
  final String info;
  final int price;
  String get file => 'music_$id.mp3';
}

class Catalog {
  static const characters = <CharacterDef>[
    // Frauen
    CharacterDef(id: 'mia', name: 'Mia', price: 0, skin: Color(0xFFF1C6A5), hair: Color(0xFF5A3825),
        hairStyle: HairStyle.ponytail, lips: Color(0xFFC2185B)),
    CharacterDef(id: 'lena', name: 'Lena', price: 300, skin: Color(0xFFF6D3BA), hair: Color(0xFFE2C275),
        hairStyle: HairStyle.long, eyes: Color(0xFF1E88E5), lips: Color(0xFFD81B60)),
    CharacterDef(id: 'aisha', name: 'Aisha', price: 500, skin: Color(0xFF8D5A3B), hair: Color(0xFF1B1210),
        hairStyle: HairStyle.bun, lips: Color(0xFF8E2442)),
    CharacterDef(id: 'yuki', name: 'Yuki', price: 800, skin: Color(0xFFEBC9A8), hair: Color(0xFF151515),
        hairStyle: HairStyle.bob, lips: Color(0xFFC62828)),
    CharacterDef(id: 'sofia', name: 'Sofia', price: 1200, skin: Color(0xFFD9A57E), hair: Color(0xFFA8361C),
        hairStyle: HairStyle.long, eyes: Color(0xFF2E7D32), lips: Color(0xFFAD1457)),
    CharacterDef(id: 'zoe', name: 'Zoe', price: 1500, skin: Color(0xFFF3CDB2), hair: Color(0xFFEC6FA8),
        hairStyle: HairStyle.ponytail, eyes: Color(0xFF6A1B9A), lips: Color(0xFFE91E63)),
    // Männer
    CharacterDef(id: 'leo', name: 'Leo', price: 400, skin: Color(0xFFEFC3A0), hair: Color(0xFF6B4A2E),
        hairStyle: HairStyle.short, body: BodyType.male),
    CharacterDef(id: 'malik', name: 'Malik', price: 700, skin: Color(0xFF6E4630), hair: Color(0xFF1A1210),
        hairStyle: HairStyle.buzz, body: BodyType.male, beard: Color(0xFF1A1210)),
    CharacterDef(id: 'kenji', name: 'Kenji', price: 900, skin: Color(0xFFE8C6A2), hair: Color(0xFF121212),
        hairStyle: HairStyle.spiky, body: BodyType.male),
    CharacterDef(id: 'jonas', name: 'Jonas', price: 1100, skin: Color(0xFFF4D0B5), hair: Color(0xFFD9B26A),
        hairStyle: HairStyle.short, body: BodyType.male, eyes: Color(0xFF1565C0), beard: Color(0xFFC9A05A)),
    // Tiere
    CharacterDef(id: 'cat', name: 'Katze Mimi', price: 1000, skin: Color(0xFFE59A4C), hair: Color(0xFFC77A2E),
        hairStyle: HairStyle.none, species: Species.cat, eyes: Color(0xFF7CB342)),
    CharacterDef(id: 'dog', name: 'Hund Bello', price: 1000, skin: Color(0xFFB98A5E), hair: Color(0xFF6D4C33),
        hairStyle: HairStyle.none, species: Species.dog, body: BodyType.male),
    CharacterDef(id: 'panda', name: 'Panda Bao', price: 1600, skin: Color(0xFF222222), hair: Color(0xFF222222),
        hairStyle: HairStyle.none, species: Species.panda, headColor: Color(0xFFF7F7F2), body: BodyType.male),
  ];

  static const outfits = <OutfitDef>[
    OutfitDef(id: 'sport', name: 'Sportlook', price: 0, top: Color(0xFF26A69A), bottom: Color(0xFF263238),
        bottomStyle: BottomStyle.leggings, shoes: Color(0xFFF5F5F5), cropTop: true),
    OutfitDef(id: 'hoodie', name: 'Hoodie', price: 150, top: Color(0xFF8D99A6), bottom: Color(0xFF37474F),
        bottomStyle: BottomStyle.pants, shoes: Color(0xFFFAFAFA), longSleeves: true, accent: Color(0xFFECEFF1)),
    OutfitDef(id: 'summer', name: 'Sommerkleid', price: 250, top: Color(0xFFFFCA28), bottom: Color(0xFFFFCA28),
        bottomStyle: BottomStyle.skirt, shoes: Color(0xFFD7CCC8), accent: Color(0xFFFFFFFF)),
    OutfitDef(id: 'hawaii', name: 'Hawaii-Hemd', price: 300, top: Color(0xFFFF7043), bottom: Color(0xFFD7C9A7),
        bottomStyle: BottomStyle.shorts, shoes: Color(0xFF8D6E63), dots: Color(0xFFFFF59D)),
    OutfitDef(id: 'tennis', name: 'Tennis', price: 350, top: Color(0xFFFAFAFA), bottom: Color(0xFFFAFAFA),
        bottomStyle: BottomStyle.skirt, shoes: Color(0xFFFFFFFF), accent: Color(0xFF43A047)),
    OutfitDef(id: 'stunt', name: 'Stuntanzug', price: 400, top: Color(0xFF212121), bottom: Color(0xFF212121),
        bottomStyle: BottomStyle.leggings, shoes: Color(0xFFFF6D00), longSleeves: true, accent: Color(0xFFFF6D00)),
    OutfitDef(id: 'wetsuit', name: 'Neoprenanzug', price: 500, top: Color(0xFF102A43), bottom: Color(0xFF102A43),
        bottomStyle: BottomStyle.leggings, shoes: Color(0xFF102A43), longSleeves: true, accent: Color(0xFF29B6F6)),
    OutfitDef(id: 'leather', name: 'Lederjacke', price: 600, top: Color(0xFF3E2723), bottom: Color(0xFF3F51B5),
        bottomStyle: BottomStyle.pants, shoes: Color(0xFF212121), longSleeves: true, accent: Color(0xFFBDBDBD)),
    OutfitDef(id: 'rocker', name: 'Rocker', price: 700, top: Color(0xFF1B1B1B), bottom: Color(0xFFB71C1C),
        bottomStyle: BottomStyle.pants, shoes: Color(0xFF1B1B1B), belt: Color(0xFFBDBDBD), accent: Color(0xFFE0E0E0)),
    OutfitDef(id: 'ninja', name: 'Ninja', price: 800, top: Color(0xFF1A1A1A), bottom: Color(0xFF1A1A1A),
        bottomStyle: BottomStyle.pants, shoes: Color(0xFF1A1A1A), longSleeves: true, mask: Color(0xFF1A1A1A),
        belt: Color(0xFFD32F2F)),
    OutfitDef(id: 'hero', name: 'Superheld', price: 1000, top: Color(0xFF1565C0), bottom: Color(0xFF1565C0),
        bottomStyle: BottomStyle.leggings, shoes: Color(0xFFC62828), longSleeves: true, cape: Color(0xFFC62828),
        mask: Color(0xFFC62828), belt: Color(0xFFFFD600), accent: Color(0xFFFFD600)),
    OutfitDef(id: 'astro', name: 'Astronaut', price: 1500, top: Color(0xFFECEFF1), bottom: Color(0xFFECEFF1),
        bottomStyle: BottomStyle.pants, shoes: Color(0xFF90A4AE), longSleeves: true, accent: Color(0xFFFF7043),
        belt: Color(0xFF90A4AE)),
    OutfitDef(id: 'gold', name: 'Goldanzug', price: 3000, top: Color(0xFFD4AF37), bottom: Color(0xFFD4AF37),
        bottomStyle: BottomStyle.leggings, shoes: Color(0xFFFFF59D), longSleeves: true, cape: Color(0xFF6A1B9A),
        accent: Color(0xFFFFF8E1)),
  ];

  static const music = <MusicTrack>[
    MusicTrack(id: 'boombap', name: 'Boom Bap', info: 'Klassischer Hip-Hop, 88 BPM', price: 0),
    MusicTrack(id: 'lofi', name: 'Lo-Fi Chill', info: 'Entspannt mit Knistern, 74 BPM', price: 300),
    MusicTrack(id: 'gfunk', name: 'West Coast', info: 'G-Funk mit Pfeif-Synth, 94 BPM', price: 500),
    MusicTrack(id: 'trap', name: 'Trap', info: 'Harte 808s und Hi-Hat-Rolls, 140 BPM', price: 800),
  ];

  static CharacterDef character(String id) =>
      characters.firstWhere((c) => c.id == id, orElse: () => characters.first);

  static OutfitDef outfit(String id) =>
      outfits.firstWhere((o) => o.id == id, orElse: () => outfits.first);

  static MusicTrack track(String id) =>
      music.firstWhere((m) => m.id == id, orElse: () => music.first);
}
