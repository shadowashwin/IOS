import 'dart:convert';

import 'package:http/http.dart' as http;

import '../SecureStorage/SecureStorageService.dart';

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.badgeLeft,
    required this.badgeRight,
    this.description,
    this.bullets = const [],
    this.images = const [],
  });

  final String id; // maps from _id
  final String title;
  final double price;
  final double originalPrice;
  final String badgeLeft; // 'FREE CONTENT' or 'PAID'
  final String badgeRight; // 'FILES' or 'NO FILES'

  // Optional extras from the API
  final String? description;
  final List<String> bullets;
  final List<String> images;

  bool get hasDiscount => originalPrice > price;

  factory Product.fromCourseJson(Map<String, dynamic> json, {String? baseUrl}) {
    final num? rawPrice = json['price'] as num?;
    final double price = (rawPrice ?? 0).toDouble();

    // Normalize bullets
    final List<String> bullets =
        (json['bullets'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    // Normalize images (fix backslashes and prefix base for relative paths)
    final List<String> rawImages =
        (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const [];
    final images = rawImages.map((p) {
      final fixed = p.replaceAll(r'\', '/');
      final isAbsolute =
          fixed.startsWith('http://') || fixed.startsWith('https://');
      if (isAbsolute || baseUrl == null || baseUrl.isEmpty) return fixed;
      // ensure no double slashes
      final trimmed = fixed.startsWith('/') ? fixed.substring(1) : fixed;
      return '$baseUrl/$trimmed';
    }).toList();

    return Product(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      price: price,
      originalPrice: (json['originalPrice'] is num)
          ? (json['originalPrice'] as num).toDouble()
          : price,
      description: (json['description'] as String?),
      bullets: bullets,
      images: images,
      badgeLeft: price == 0 ? 'FREE CONTENT' : 'PAID',
      badgeRight: images.isNotEmpty ? 'FILES' : 'NO FILES',
    );
  }
}

class ProductApi {
  static const String _path = '/api/courses';

  static Future<String> _getToken() async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();
    if (user == null) {
      throw Exception('No user data found in secure storage.');
    }
    final token = (user['token'] ?? '').toString();
    if (token.isEmpty) {
      throw Exception('No token found in secure storage.');
    }
    return token;
  }

  static Future<List<Product>> fetch({String? baseUrlOverride}) async {
    final base = "https://backend.obgynprep.store";

    final uri = Uri.parse('$base$_path');
    final token = await _getToken();

    final res = await http
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode == 401) {
      // Token likely expired/invalid – surface a helpful error
      throw Exception('Unauthorized (401): token invalid or expired.');
    }
    if (res.statusCode != 200) {
      throw Exception(
        'Failed to load courses (${res.statusCode}): ${res.body}',
      );
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Unexpected response shape: expected a List.');
    }

    // 👇 Print how many courses came from the API
    print('Number of courses received: ${decoded.length}');

    return decoded
        .whereType<Map<String, dynamic>>()
        .map<Product>((m) => Product.fromCourseJson(m, baseUrl: base))
        .toList(growable: false);
  }
}
