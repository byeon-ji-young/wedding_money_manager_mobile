import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const WeddingMoneyManagerApp());
}

class WeddingMoneyManagerApp extends StatelessWidget {
  const WeddingMoneyManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '결혼자금관리',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
        textTheme: GoogleFonts.ibmPlexSansKrTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
