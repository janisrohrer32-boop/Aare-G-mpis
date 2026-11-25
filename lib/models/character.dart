import 'package:flutter/painting.dart';

enum HairStyle { ponytail, long, bob, bun }

enum BottomStyle { leggings, shorts, skirt, pants }

/// Eine spielbare Figur (Aussehen von Haut und Haaren).
class CharacterDef {
  const CharacterDef({
    required this.id,
    required this.name,
    required this.price,
    required this.skin,
    required this.hair,
    required this.hairStyle,
    this.lips = const Color(0xFFC2185B),
    this.eyes = const Color(0xFF4E342E),
  });

  final String id;
  final String name;
  final int price;
  final Color skin;
  final Color hair;
  final HairStyle hairStyle;
  final Color lips;
  final Color eyes;
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
    this.cape,
    this.mask,
    this.belt,
    this.accent,
  });

  final String id;
  final String name;
  final int price;
  final Color top;
  final Color bottom;
  final BottomStyle bottomStyle;
  final Color shoes;
  final bool longSleeves;
  final Color? cape;
  final Color? mask;
  final Color? belt;

  /// Zweitfarbe, z. B. Logo oder Streifen.
  final Color? accent;
}

class Catalog {
  static const characters = <CharacterDef>[
    CharacterDef(
      id: 'mia',
      name: 'Mia',
      price: 0,
      skin: Color(0xFFF1C6A5),
      hair: Color(0xFF5A3825),
      hairStyle: HairStyle.ponytail,
    ),
    CharacterDef(
      id: 'lena',
      name: 'Lena',
      price: 300,
      skin: Color(0xFFF6D3BA),
      hair: Color(0xFFE2C275),
      hairStyle: HairStyle.long,
      eyes: Color(0xFF1E88E5),
    ),
    CharacterDef(
      id: 'aisha',
      name: 'Aisha',
      price: 500,
      skin: Color(0xFF8D5A3B),
      hair: Color(0xFF1B1210),
      hairStyle: HairStyle.bun,
      lips: Color(0xFF8E2442),
    ),
    CharacterDef(
      id: 'yuki',
      name: 'Yuki',
      price: 800,
      skin: Color(0xFFEBC9A8),
      hair: Color(0xFF151515),
      hairStyle: HairStyle.bob,
    ),
    CharacterDef(
      id: 'sofia',
      name: 'Sofia',
      price: 1200,
      skin: Color(0xFFD9A57E),
      hair: Color(0xFFA8361C),
      hairStyle: HairStyle.long,
      eyes: Color(0xFF2E7D32),
    ),
  ];

  static const outfits = <OutfitDef>[
    OutfitDef(
      id: 'sport',
      name: 'Sportlook',
      price: 0,
      top: Color(0xFF26A69A),
      bottom: Color(0xFF263238),
      bottomStyle: BottomStyle.leggings,
      shoes: Color(0xFFF5F5F5),
    ),
    OutfitDef(
      id: 'summer',
      name: 'Sommerkleid',
      price: 250,
      top: Color(0xFFFFCA28),
      bottom: Color(0xFFFFCA28),
      bottomStyle: BottomStyle.skirt,
      shoes: Color(0xFFD7CCC8),
      accent: Color(0xFFFFFFFF),
    ),
    OutfitDef(
      id: 'stunt',
      name: 'Stuntanzug',
      price: 400,
      top: Color(0xFF212121),
      bottom: Color(0xFF212121),
      bottomStyle: BottomStyle.leggings,
      shoes: Color(0xFFFF6D00),
      longSleeves: true,
      accent: Color(0xFFFF6D00),
    ),
    OutfitDef(
      id: 'leather',
      name: 'Lederjacke',
      price: 600,
      top: Color(0xFF3E2723),
      bottom: Color(0xFF3F51B5),
      bottomStyle: BottomStyle.pants,
      shoes: Color(0xFF212121),
      longSleeves: true,
      accent: Color(0xFFBDBDBD),
    ),
    OutfitDef(
      id: 'ninja',
      name: 'Ninja',
      price: 800,
      top: Color(0xFF1A1A1A),
      bottom: Color(0xFF1A1A1A),
      bottomStyle: BottomStyle.pants,
      shoes: Color(0xFF1A1A1A),
      longSleeves: true,
      mask: Color(0xFF1A1A1A),
      belt: Color(0xFFD32F2F),
    ),
    OutfitDef(
      id: 'hero',
      name: 'Superheldin',
      price: 1000,
      top: Color(0xFF1565C0),
      bottom: Color(0xFF1565C0),
      bottomStyle: BottomStyle.leggings,
      shoes: Color(0xFFC62828),
      longSleeves: true,
      cape: Color(0xFFC62828),
      mask: Color(0xFFC62828),
      belt: Color(0xFFFFD600),
      accent: Color(0xFFFFD600),
    ),
  ];

  static CharacterDef character(String id) =>
      characters.firstWhere((c) => c.id == id, orElse: () => characters.first);

  static OutfitDef outfit(String id) =>
      outfits.firstWhere((o) => o.id == id, orElse: () => outfits.first);
}
