import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/storage_service.dart';
import 'widgets.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.storage});
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFECEFF3),
        appBar: AppBar(
          title: const Text('Shop', style: TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: const Color(0xFF37474F),
          foregroundColor: Colors.white,
          actions: [
            ListenableBuilder(
              listenable: storage,
              builder: (_, _) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CoinBadge(coins: storage.coins),
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Color(0xFFFFB300),
            tabs: [Tab(text: 'Charaktere'), Tab(text: 'Outfits')],
          ),
        ),
        body: ListenableBuilder(
          listenable: storage,
          builder: (context, _) => TabBarView(children: [
            _grid(context, [
              for (final c in Catalog.characters)
                _ShopItem(
                  name: c.name,
                  price: c.price,
                  owned: storage.ownsCharacter(c.id),
                  selected: storage.character.id == c.id,
                  preview: FigurePreview(
                      character: c, outfit: storage.outfit, style: 4, height: 150),
                  onBuy: () => _buy(context, 'char', c.id, c.price),
                  onSelect: () => storage.selectCharacter(c.id),
                ),
            ]),
            _grid(context, [
              for (final o in Catalog.outfits)
                _ShopItem(
                  name: o.name,
                  price: o.price,
                  owned: storage.ownsOutfit(o.id),
                  selected: storage.outfit.id == o.id,
                  preview: FigurePreview(
                      character: storage.character, outfit: o, style: 4, height: 150),
                  onBuy: () => _buy(context, 'outfit', o.id, o.price),
                  onSelect: () => storage.selectOutfit(o.id),
                ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _grid(BuildContext context, List<Widget> items) => GridView.count(
        crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 2,
        padding: const EdgeInsets.all(14),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
        children: items,
      );

  void _buy(BuildContext context, String kind, String id, int price) {
    final ok = storage.buy(kind: kind, id: id, price: price);
    if (ok) {
      kind == 'char' ? storage.selectCharacter(id) : storage.selectOutfit(id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Dir fehlen noch ${price - storage.coins} Münzen. Spring weiter!'),
      ));
    }
  }
}

class _ShopItem extends StatelessWidget {
  const _ShopItem({
    required this.name,
    required this.price,
    required this.owned,
    required this.selected,
    required this.preview,
    required this.onBuy,
    required this.onSelect,
  });

  final String name;
  final int price;
  final bool owned;
  final bool selected;
  final Widget preview;
  final VoidCallback onBuy;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: selected ? 4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: owned ? onSelect : onBuy,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: selected ? const Color(0xFFFFB300) : Colors.transparent, width: 3),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Expanded(child: Center(child: preview)),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 6),
            if (selected)
              const Text('Ausgewählt', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w700))
            else if (owned)
              const Text('Antippen zum Anziehen', style: TextStyle(color: Colors.black54, fontSize: 12))
            else
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 18),
                const SizedBox(width: 4),
                Text('$price', style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
          ]),
        ),
      ),
    );
  }
}
