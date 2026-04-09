import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF6C63FF), // Soft modern purple
    hintColor: const Color(0xFF00C9A7), // Teal accent
    scaffoldBackgroundColor: const Color.fromARGB(255, 12, 13, 20), // Soft clean background
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6C63FF),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        shadowColor: Colors.black26,
        elevation: 6,
      ),
    ),
    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
      bodyMedium: TextStyle(color: Color(0xFF4A4A4A)),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: const Color(0xFF00C9A7),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0F172A), // Deep navy-black
    hintColor: const Color(0xFF22C55E), // Neon green accent
    scaffoldBackgroundColor: const Color(
      0xFF020617,
    ), // Ultra dark (almost black)
    cardColor: const Color(0xFF0F172A), // Smooth dark card
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF020617),
      foregroundColor: Color(0xFFE2E8F0), // Soft white
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF22C55E), // Neon green
        foregroundColor: Colors.black, // contrast pop
        shadowColor: Colors.greenAccent,
        elevation: 10,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE2E8F0)), // soft white
      bodyMedium: TextStyle(color: Color(0xFF94A3B8)), // muted grey
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF22C55E), // Neon green
      onPrimary: Colors.black,
      secondary: Color(0xFF38BDF8), // Cyan accent
      onSecondary: Colors.black,
      surface: Color(0xFF0F172A),
      onSurface: Color(0xFFE2E8F0),
      error: Color(0xFFF43F5E), // modern red
      onError: Colors.white,
    ),
  );

  ThemeMode _themeMode = ThemeMode.dark; // Default to dark theme

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners(); // Notify listeners when the theme changes
  }
}
