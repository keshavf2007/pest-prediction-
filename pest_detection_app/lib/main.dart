import 'package:flutter/material.dart';
import 'package:pest_detection_app/screens/home_screen.dart';

void main() {
  runApp(const PestDetectionApp());
}

/// Main application widget
class PestDetectionApp extends StatelessWidget {
  const PestDetectionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pest Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        primaryColor: Colors.green[700],
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
