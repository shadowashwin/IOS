import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Components/Chips.dart';
import '../Components/pdfviewer.dart';
import '../Components/sticky_buy_bar.dart';
import '../Modal/Product.dart';
import '../SecureStorage/SecureStorageService.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({
    super.key,
    required this.product,
    required this.screen,
  });
  final Product product;
  final String screen;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          titleSpacing: 0,
          title: Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: OverviewTab(product: product),
        bottomNavigationBar: screen == "store"
            ? Container(height: 0)
            : StickyBuyBar(product: product),
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const SizedBox(height: 8),
        _TitleLikesRow(title: product.title),
        const SizedBox(height: 10),
        _TagsRow(badgeLeft: product.badgeLeft, badgeRight: product.badgeRight),
        const SizedBox(height: 12),
        _GalleryRow(images: product.images, id: product.id),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _AboutSection(
          bullets: product.bullets,
          description: product.description,
        ),
        // const SizedBox(height: 6),
        // PricingDetailsCard(product: product),
        // const SizedBox(height: 18),
      ],
    );
  }
}

class EmptyContentTab extends StatelessWidget {
  const EmptyContentTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Content'));
  }
}

/// TITLE + (optional) actions
class _TitleLikesRow extends StatelessWidget {
  const _TitleLikesRow({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Column(
            children: const [
              Icon(Icons.add_shopping_cart_outlined, size: 25),
              SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// BADGES (from Product.badgeLeft/right)
class _TagsRow extends StatelessWidget {
  const _TagsRow({required this.badgeLeft, required this.badgeRight});
  final String badgeLeft;
  final String badgeRight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Wrap(
        spacing: 8,
        children: [AppChip(badgeLeft), AppChip(badgeRight)],
      ),
    );
  }
}

/// LEFT: slideable image panel (uses product.images)
/// RIGHT: PDF card
class _GalleryRow extends StatefulWidget {
  const _GalleryRow({required this.images, required this.id});
  final List<String> images;
  final String id;

  @override
  State<_GalleryRow> createState() => _GalleryRowState();
}

class _GalleryRowState extends State<_GalleryRow> {
  late final PageController _pageController;
  int _index = 0;
  static const String base =
      "https://backend.obgynprep.store/api/courses";

  static Future<Map<String, dynamic>> fetchCoursePdf(String id) async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();
    final token = user?['token'];

    if (token == null) {
      throw Exception("No token found in storage.");
    }

    final uri = Uri.parse("$base/$id/pdf");
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch PDF (${res.statusCode}): ${res.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _hasImages => widget.images.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          // LEFT: images (slideable)
          Expanded(
            child: AspectRatio(
              aspectRatio: 16 / 12,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _hasImages
                        ? PageView.builder(
                            controller: _pageController,
                            onPageChanged: (i) => setState(() => _index = i),
                            itemCount: total,
                            itemBuilder: (_, i) =>
                                _ImageTile(url: widget.images[i]),
                          )
                        : const _GreenPlaceholderTile(),
                  ),

                  // Counter (1/N) only if we have images
                  if (_hasImages)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _CountPill(current: _index + 1, total: total),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // RIGHT: PDF Card
          Expanded(
            child: AspectRatio(
              aspectRatio: 16 / 12,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfViewerPage(courseId: widget.id),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE1E6EE)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.picture_as_pdf,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Image tile with graceful error/placeholder
class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF7EF),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _GreenPlaceholderTile(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      ),
    );
  }
}

/// Styled green placeholder (matches your earlier card)
class _GreenPlaceholderTile extends StatelessWidget {
  const _GreenPlaceholderTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCDE8CC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9BC69E)),
      ),
      padding: const EdgeInsets.all(10),
      child: const Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Course Preview',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

/// little "1/N" counter pill
class _CountPill extends StatelessWidget {
  const _CountPill({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$current / $total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ABOUT section: uses product.description (optional) and product.bullets
class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.bullets, this.description});
  final List<String> bullets;
  final String? description;

  @override
  Widget build(BuildContext context) {
    Widget bullet(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );

    final hasBullets = bullets.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'About This Course',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),

        // Prefer bullets if present, otherwise show description, otherwise fallback bullets
        if (hasBullets)
          ...bullets.map(bullet)
        else if ((description ?? '').trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(description!.trim()),
          )
        else ...[
          bullet('High-quality curated content for quick mastery'),
          bullet('Hands-on concepts and practical examples'),
          bullet('Well-structured and easy to revise'),
        ],
      ],
    );
  }
}
