import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      home: LoginScreenWrapper(toggleTheme: toggleTheme),
    );
  }
}

// 🔥 WRAPPER (PASS TO ALL SCREENS)
class LoginScreenWrapper extends StatelessWidget {
  final VoidCallback toggleTheme;

  LoginScreenWrapper({required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return LoginScreen(toggleTheme: toggleTheme);
  }
}