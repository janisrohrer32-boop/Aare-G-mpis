import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/menu_screen.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final storage = await StorageService.create();
  runApp(CliffDiveApp(storage: storage));
}

class CliffDiveApp extends StatelessWidget {
  const CliffDiveApp({super.key, required this.storage});
  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cliff Dive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0288D1)),
        useMaterial3: true,
      ),
      home: MenuScreen(storage: storage),
    );
  }
}
