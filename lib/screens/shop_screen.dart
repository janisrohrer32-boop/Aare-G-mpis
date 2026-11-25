import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'widgets.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key, required this.storage, required this.audio});
  final StorageService storage;
  final AudioService audio;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
            tabs: [Tab(text: 'Figuren'), Tab(text: 'Outfits'), Tab(text: 'Musik')],
          ),
        ),
        body: ListenableBuilder(
          listenable: storage,
          builder: (context, _) => TabBarView(children: [
            _characters(context),
            _sections(context, [
              ('', [
                for (final o in Catalog.outfits)
                  _ShopItem(
                    name: o.name,
                    price: o.price,
                    owned: storage.ownsOutfit(o.id),
                    selected: storage.outfit.id == o.id,
                    preview: FigurePreview(character: storage.character, outfit: o, style: 4, height: 150),
                    onBuy: () => _buy(context, 'outfit', o.id, o.price),
                    onSelect: () => storage.selectOutfit(o.id),
                  ),
              ]),
            ]),
            _music(context),
          ]),
        ),
      ),
    );
  }

  Widget _characters(BuildContext context) {
    final groups = <String, List<CharacterDef>>{};
    for (final c in Catalog.characters) {
      groups.putIfAbsent(c.group, () => []).add(c);
    }
    return _sections(context, [
      for (final g in groups.entries)
        (
          g.key,
          [
            for (final c in g.value)
              _ShopItem(
                name: c.name,
                price: c.price,
                owned: storage.ownsCharacter(c.id),
                selected: storage.character.id == c.id,
                preview: FigurePreview(character: c, outfit: storage.outfit, style: 4, height: 150),
                onBuy: () => _buy(context, 'char', c.id, c.price),
                onSelect: () => storage.selectCharacter(c.id),
              ),
          ]
        ),
    ]);
  }

  Widget _sections(BuildContext context, List<(String, List<Widget>)> sections) {
    final cols = MediaQuery.sizeOf(context).width > 600 ? 3 : 2;
    return CustomScrollView(slivers: [
      for (final (title, items) in sections) ...[
        if (title.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(14),
          sliver: SliverGrid.count(
            crossAxisCount: cols,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
            children: items,
          ),
        ),
      ],
    ]);
  }

  Widget _music(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        for (final m in Catalog.music)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: storage.track.id == m.id ? const Color(0xFFFFB300) : Colors.transparent,
                      width: 3),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF37474F),
                  child: Icon(Icons.music_note, color: Colors.white),
                ),
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(m.info),
                trailing: storage.track.id == m.id
                    ? const Text('Läuft', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w700))
                    : storage.ownsTrack(m.id)
                        ? const Text('Abspielen')
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.monetization_on, color: Color(0xFFFFC107), size: 18),
                            const SizedBox(width: 4),
                            Text('${m.price}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          ]),
                onTap: () {
                  if (!storage.ownsTrack(m.id) && !_buyOk(context, 'music', m.id, m.price)) return;
                  storage.selectTrack(m.id);
                  audio.setTrack(m.file);
                  audio.startMusic();
                },
              ),
            ),
          ),
      ],
    );
  }

  bool _buyOk(BuildContext context, String kind, String id, int price) {
    final ok = storage.buy(kind: kind, id: id, price: price);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Dir fehlen noch ${price - storage.coins} Münzen. Spring weiter!'),
      ));
    }
    return ok;
  }

  void _buy(BuildContext context, String kind, String id, int price) {
    if (_buyOk(context, kind, id, price)) {
      kind == 'char' ? storage.selectCharacter(id) : storage.selectOutfit(id);
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
              const Text('Antippen zum Wählen', style: TextStyle(color: Colors.black54, fontSize: 12))
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
