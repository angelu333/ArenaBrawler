import 'package:flutter/material.dart';
import 'package:juego_happy/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const HomeScreen(),
    );
  }
}
