import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:obgynprep/Screens/LoginScreen.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _titles = ['Home', 'Store', 'Chats', 'Profile'];

  late Future<List<Product>> productsFuture;
  final base = "https://horribly-superb-bedbug.ngrok-free.app";

  String token = "";
  String name = "";

  Future<void> loadUserData() async {
    final storage = SecureStorageService();
    final user = await storage.getUserData(); // await here!

    if (user != null) {
      setState(() {
        token = (user['token'] ?? '').toString();
        name = (user['name'] ?? '').toString();
        _titles[3] = name;
      });
    }
  }

  Future<void> logout({bool androidEmulator = false}) async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();

    if (user == null || user['token'] == null) {
      throw Exception("No user logged in or token missing.");
    }

    final token = user['token'];
    final uri = Uri.parse('${base}/api/users/logout');

    final res = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await storage.clearUserData();
      // BottomMessage.show(
      //   context,
      //   text: 'Logged Out!',
      //   type: BottomMessageType.success,
      //   autoCloseAfter: const Duration(seconds: 2),
      // );
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

  @override
  void initState() {
    super.initState();
    productsFuture = ProductApi.fetch();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
                  await logout(androidEmulator: true); // call your function
                }
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          FutureBuilder<List<Product>>(
            future: productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final products = snapshot.data ?? const <Product>[];
              if (products.isEmpty) {
                return const Center(child: Text('No courses available'));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    ProductCard(product: products[index]),
              );
            },
          ),
          const StoreTab(),
          const SizedBox.shrink(),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryBlue.withOpacity(.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_mall_directory_outlined),
            selectedIcon: Icon(Icons.store_mall_directory),
            label: 'Store',
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
    );
  }
}
