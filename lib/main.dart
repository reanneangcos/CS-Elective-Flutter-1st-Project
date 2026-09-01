import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'streaming_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const LumenApp());
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Lumen',
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: Color(0xFFA6F4C5),
          scaffoldBackgroundColor: Color(0xFF090A18),
        ),
        home: LumenHomeScreen(),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumen',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090A18),
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF8B7CF6),
              brightness: Brightness.dark,
            ).copyWith(
              primary: const Color(0xFFA6F4C5),
              secondary: const Color(0xFF8B7CF6),
              surface: const Color(0xFF15172A),
            ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const LumenHomeScreen(),
    );
  }
}
