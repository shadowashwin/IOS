import 'package:flutter/material.dart';

import 'Core/Theme/app_theme.dart';
import 'Screens/home_screen.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Store',
      theme: AppTheme.light,
      home: HomeScreen(),
    );
  }
}
