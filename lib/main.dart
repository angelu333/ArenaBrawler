import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:juego_happy/screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dftxwwgkfdqwfohhyqkh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmdHh3d2drZmRxd2ZvaGh5cWtoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NTQzNjYsImV4cCI6MjA3NzIzMDM2Nn0.GFZw_Gw2KYWWSI41DA8vEfZTc14vzi5f4YoJhkCYIjc',
  );

  // Forzar modo horizontal y pantalla completa
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arena Brawler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: const LoadingScreen(),
    );
  }
}
