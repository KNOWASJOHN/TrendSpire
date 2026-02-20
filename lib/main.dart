// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation only (cleaner for demo)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Status bar with dark icons (light background)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // dark icons on light bg
      systemNavigationBarColor: Color(0xFFF2F2F7),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TrendWiseApp());
}

class TrendWiseApp extends StatelessWidget {
  const TrendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrendWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const DashboardScreen(),
    );
  }
}
