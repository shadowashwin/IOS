import 'package:flutter/material.dart';
import 'package:obgynprep/Screens/home_screen.dart';

import 'Core/Theme/app_theme.dart';
import 'Screens/LoginScreen.dart';
import 'SecureStorage/SecureStorageService.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  Future<bool> _hasUserData() async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();
    return user != null;
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
