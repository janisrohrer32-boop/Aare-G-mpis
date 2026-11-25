/// Ein Trick: entsteht, wenn die Figur eine volle Umdrehung schafft.
class Trick {
  const Trick({required this.id, required this.name, required this.basePoints});

  final String id;
  final String name;
  final int basePoints;

  static const backflip =
      Trick(id: 'backflip', name: 'Rückwärtssalto', basePoints: 100);
  static const frontflip =
      Trick(id: 'frontflip', name: 'Vorwärtssalto', basePoints: 80);
}
