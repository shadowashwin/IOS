import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:obgynprep/Screens/LoginScreen.dart';
import 'package:obgynprep/Screens/chat_tab.dart';
import 'package:obgynprep/Screens/profile_tab.dart';
import 'package:obgynprep/Screens/store_tab.dart';

import '../Components/product_card.dart';
import '../Core/Constants/app_colors.dart';
import '../Modal/Product.dart';
import '../SecureStorage/SecureStorageService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  // final List<String> _titles = ['Home', 'Store', 'Chats', 'Profile'];
  final List<String> _titles = ['My Courses', 'Chats', 'Profile'];

  // late Future<List<Product>> productsFuture;
  // final base = "https://backend.obgynprep.store";
  final base = "https://3ae4-2001-4490-4465-3f19-2dce-8b0e-c6-29ae.ngrok-free.app";

  String token = "";
  String name = "";

  // ----- LIFECYCLE -----
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // productsFuture = ProductApi.fetch();
    loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshProducts(); // auto refresh on resume
    }
  }

  // ----- DATA LOAD / REFRESH -----
  Future<void> loadUserData() async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();

    if (user != null) {
      setState(() {
        token = (user['token'] ?? '').toString();
        name = (user['name'] ?? '').toString();
        if (name.isNotEmpty) _titles[2] = name;
      });
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {
      // productsFuture = ProductApi.fetch();
    });
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  // ----- AUTH -----
  Future<void> logout({bool androidEmulator = false}) async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();

    if (user == null || user['token'] == null) {
      throw Exception("No user logged in or token missing.");
    }

    final token = user['token'];
    final uri = Uri.parse('$base/api/users/logout');

    final res = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      await storage.clearUserData();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loginscreen()),
      );
    } else {
      throw Exception("Logout failed (${res.statusCode}): ${res.body}");
    }
  }

  Future<bool?> _showLogoutConfirmDialog(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Are you sure you want to log out?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ----- BACK BUTTON HANDLING -----
  Future<bool> _onWillPop() async {
    // If NOT on Home tab, go to Home instead of exiting
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false; // don't pop the route
    }

    // Already on Home tab → ask if user wants to exit
    final shouldExit =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Exit app?'),
              content: const Text(
                'Do you really want to close the application?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;

    return shouldExit; // true → pop & exit, false → stay
  }

  // ----- UI -----
  @override
  Widget build(BuildContext context) {
    final firstLetter = name.isNotEmpty
        ? name.characters.first.toUpperCase()
        : '?';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leadingWidth: 60,
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              _titles[_currentIndex],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  final shouldLogout = await _showLogoutConfirmDialog(context);
                  if (shouldLogout == true) {
                    await logout(androidEmulator: true);
                  }
                },
              ),
            ),
          ],
        ),

        body: IndexedStack(
          index: _currentIndex,
          children: const [
            StoreTab(),
            ChatTab(),
            ProfileTab(),
          ],
        ),

        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) {
            setState(() => _currentIndex = i);
            if (i == 0) {
              // _refreshProducts();
            }
          },
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryBlue.withOpacity(.12),
          destinations: const [
            // NavigationDestination(
            //   icon: Icon(Icons.home_outlined),
            //   selectedIcon: Icon(Icons.home),
            //   label: 'Home',
            // ),
            // NavigationDestination(
            //   icon: Icon(Icons.store_mall_directory_outlined),
            //   selectedIcon: Icon(Icons.store_mall_directory),
            //   label: 'Store',
            // ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'My Courses',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
