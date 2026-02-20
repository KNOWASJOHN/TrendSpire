// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation only (cleaner for demo)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Make status bar and nav bar transparent to match dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF08080F),
      systemNavigationBarIconBrightness: Brightness.light,
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
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: AppTheme.theme,
      home: const DashboardScreen(),
    );
  }
}
