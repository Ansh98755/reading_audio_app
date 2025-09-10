import 'package:flutter/material.dart';
import 'package:reading_audio_app/screens/chapters_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reading Audio App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const ChaptersScreen(),
    );
  }
}