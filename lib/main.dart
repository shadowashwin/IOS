import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:obgynprep/Screens/home_screen.dart';

import 'Core/Theme/app_theme.dart';
import 'Screens/LoginScreen.dart';
import 'SecureStorage/SecureStorageService.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _noScreenshot = NoScreenshot.instance;
  bool screenshot_disabled = true;

  Future<bool> _hasUserData() async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();

    // Check if user exists and has a valid token
    if (user == null) return false;

    final token = user['token'];
    if (token == null || token.isEmpty) {
      // Token is missing or empty, clear the stale data
      await storage.clearUserData();
      return false;
    }

    return true;
  }

  Future<void> _disableScreenshots() async {
    await _noScreenshot.screenshotOff(); // disables screenshot + recording
  }

  @override
  void initState() {
    super.initState();
    if (screenshot_disabled) {
      _disableScreenshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Store',
      theme: AppTheme.light,
      home: FutureBuilder<bool>(
        future: _hasUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text("Something went wrong")),
            );
          }
          final loggedIn = snapshot.data ?? false;
          return loggedIn ? const HomeScreen() : const Loginscreen();
        },
      ),
    );
  }
}
