import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';

void main() {
  // Flutter 플러그인 사용하기 전 초기화 진행
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 실행
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
