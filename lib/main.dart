import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/menu_screen.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final storage = await StorageService.create();
  final audio = AudioService(muted: storage.muted)..track = storage.track.file;
  audio.preload();
  runApp(CliffDiveApp(storage: storage, audio: audio));
}

class CliffDiveApp extends StatelessWidget {
  const CliffDiveApp({super.key, required this.storage, required this.audio});
  final StorageService storage;
  final AudioService audio;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cliff Dive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF37474F)),
        useMaterial3: true,
      ),
      home: MenuScreen(storage: storage, audio: audio),
    );
  }
}
