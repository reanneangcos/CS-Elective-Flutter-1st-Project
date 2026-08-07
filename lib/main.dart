import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'streaming_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const StreamBoxApp());
}

class StreamBoxApp extends StatelessWidget {
  const StreamBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StreamBox',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0A0E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB347),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const StreamingHomeScreen(),
    );
  }
}
