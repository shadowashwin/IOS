import 'package:flutter/material.dart';

import '../Components/Chips.dart';
import '../Components/pricing_details_card.dart';
import '../Components/sticky_buy_bar.dart';
import '../Modal/Product.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key, required this.product});
  final Product product;

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
          // actions: const [
          //   Icon(Icons.share_outlined),
          //   SizedBox(width: 12),
          //   Icon(Icons.more_vert),
          //   SizedBox(width: 8),
          // ],
          // bottom: const TabBar(
          //   isScrollable: true,
          //   labelColor: Colors.white,
          //   unselectedLabelColor: Colors.black87,
          //   indicatorSize: TabBarIndicatorSize.label,
          //   indicator: BoxDecoration(
          //     color: AppColors.primaryBlue,
          //     borderRadius: BorderRadius.all(Radius.circular(28)),
          //   ),
          //   tabs: [
          //     Tab(text: 'Overview'),
          //     Tab(text: 'Content'),
          //   ],
          // ),
        ),
        // body: const TabBarView(children: [OverviewTab(), EmptyContentTab()]),
        body: OverviewTab(product: product),
        bottomNavigationBar: StickyBuyBar(product: product),
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
        const _TitleLikesRow(),
        const SizedBox(height: 10),
        const _TagsRow(),
        const SizedBox(height: 12),
        const _GalleryRow(),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        const _AboutSection(),
        const SizedBox(height: 6),
        PricingDetailsCard(product: product),
        const SizedBox(height: 18),
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

class _TitleLikesRow extends StatelessWidget {
  const _TitleLikesRow();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              'Master Notes: DNB Obstetrics & Gynecology Topic-wise & Year-wise Solved Papers (2012–2024)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          Column(
            children: const [
              Icon(Icons.thumb_up_alt_outlined, size: 20),
              SizedBox(height: 4),
              Text('98', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  const _TagsRow();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: Wrap(
        spacing: 8,
        children: [AppChip('FREE CONTENT'), AppChip('PDFS')],
      ),
    );
  }
}

class _GalleryRow extends StatelessWidget {
  const _GalleryRow();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 16 / 12,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCDE8CC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF9BC69E)),
                ),
                padding: const EdgeInsets.all(10),
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'DNB Obstetrics & Gynecology',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AspectRatio(
              aspectRatio: 16 / 12,
              child: InkWell(
                onTap: () {},
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

class _AboutSection extends StatelessWidget {
  const _AboutSection();
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
        bullet('Topic-wise & Solved Answers (2012–2024)'),
        bullet('Year-wise Solved Answers from 2017 to 2024'),
        bullet('Includes DNB Diploma Papers with Structured Answers'),
        bullet('Concise & Bullet-Point Format — ideal for revision'),
        // const Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
        //   child: Text(
        //     'Read More',
        //     style: TextStyle(
        //       color: AppColors.primaryBlue,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
