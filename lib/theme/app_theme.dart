import 'package:flutter/material.dart';

class AppTheme {

  // 🔵 LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    primaryColor: Color(0xFF0D47A1),

    scaffoldBackgroundColor: Colors.grey[100],

    // ✅ CARD COLOR FIX
    cardColor: Colors.white,

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0D47A1),
      foregroundColor: Colors.white,
    ),

    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(),
    ),
  );

  // 🌙 DARK THEME (🔥 IMPORTANT FIX HERE)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: Color(0xFF121212),

    // ✅ CARD COLOR FIX (NO WHITE BOX)
    cardColor: Color(0xFF1E1E1E),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),

    textTheme: TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      // ✅ FIX TEXTFIELD BACKGROUND
      fillColor: Color(0xFF2A2A2A),

      border: OutlineInputBorder(),
    ),
  );
}