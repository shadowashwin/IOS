import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Components/Chips.dart';
import '../Modal/Product.dart';
import '../SecureStorage/SecureStorageService.dart';
import 'course_detail_screen.dart';

class StoreTab extends StatefulWidget {
  const StoreTab({super.key});

  @override
  State<StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  final TextEditingController _search = TextEditingController();
  final String _base = "https://backend.obgynprep.store";

  late Future<List<Product>> _purchasedFuture;

  Future<List<Product>> fetch() async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();
    final token = user?['token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('No token found. Please login again.');
    }

    final uri = Uri.parse('$_base/api/courses/purchased');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed (${res.statusCode}): ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected response: expected a List.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((m) => Product.fromCourseJson(m, baseUrl: _base))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    // ✅ assign the future
    _purchasedFuture = fetch();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: 'Search by Name',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF0F2F5),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 32),

        // Use a FutureBuilder to show count + list
        FutureBuilder<List<Product>>(
          future: _purchasedFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Error: ${snap.error}')),
              );
            }

            final items = snap.data ?? const <Product>[];
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No purchased courses yet')),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic count
                Text(
                  'Courses (${items.length})',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),

                // Render list INSIDE parent ListView safely
                ListView.separated(
                  shrinkWrap: true, // ✅ important when nesting lists
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return Column(
                      children: [
                        StoreListItem(product: p),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class StoreListItem extends StatelessWidget {
  const StoreListItem({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseDetailPage(product: product, screen: "store"),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: AspectRatio(
              aspectRatio: 16 / 12,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCDE8CC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF9BC69E)),
                ),
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    // Show first bullet/title fallback
                    (product.bullets.isNotEmpty
                            ? product.bullets.first
                            : product.title)
                        .toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (product.badgeLeft.trim().isNotEmpty)
                      AppChip(product.badgeLeft),
                    if (product.badgeRight.trim().isNotEmpty)
                      AppChip(product.badgeRight),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
