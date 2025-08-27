import 'package:flutter/material.dart';

import '../Components/Chips.dart';
import '../Modal/Product.dart';
import 'course_detail_screen.dart';

class StoreTab extends StatefulWidget {
  const StoreTab({super.key});

  @override
  State<StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends State<StoreTab> {
  final TextEditingController _search = TextEditingController();

  final List<Product> _items = const [
    Product(
      title: 'Diploma Theory Papers — June 2024 & December 2024',
      price: 0,
      originalPrice: 0,
      discountLabel: '',
      badgeLeft: 'FILES',
      badgeRight: '',
    ),
    Product(
      title:
          'Master Notes: DNB Obstetrics & Gynecology Topic-wise & Year-wise...',
      price: 0,
      originalPrice: 0,
      discountLabel: '28% OFF',
      badgeLeft: 'FREE CONTENT',
      badgeRight: 'FILES',
    ),
  ];

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
        // const Text(
        //   'COURSES IN',
        //   style: TextStyle(
        //     color: Colors.black54,
        //     fontSize: 12,
        //     letterSpacing: .6,
        //     fontWeight: FontWeight.w700,
        //   ),
        // ),
        // const SizedBox(height: 6),
        // Row(
        //   children: [
        //     TextButton.icon(
        //       style: TextButton.styleFrom(padding: EdgeInsets.zero),
        //       onPressed: () async {
        //         final picked = await showModalBottomSheet<String>(
        //           context: context,
        //           showDragHandle: true,
        //           builder: (ctx) => ListView(
        //             children: [
        //               ListTile(
        //                 title: const Text('Nursing/Mbbs'),
        //                 onTap: () => Navigator.pop(ctx, 'Nursing/Mbbs'),
        //               ),
        //               ListTile(
        //                 title: const Text('Dentistry'),
        //                 onTap: () => Navigator.pop(ctx, 'Dentistry'),
        //               ),
        //               ListTile(
        //                 title: const Text('Pharmacy'),
        //                 onTap: () => Navigator.pop(ctx, 'Pharmacy'),
        //               ),
        //             ],
        //           ),
        //         );
        //         if (picked != null) setState(() => _category = picked);
        //       },
        //       icon: const Icon(
        //         Icons.keyboard_arrow_down_rounded,
        //         color: AppColors.primaryBlue,
        //       ),
        //       label: Text(
        //         _category,
        //         style: const TextStyle(
        //           color: AppColors.primaryBlue,
        //           fontSize: 18,
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        const Divider(height: 32),
        Text(
          'Courses (${_items.length})',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ..._items.map(
          (p) => Column(
            children: [
              StoreListItem(product: p),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
            ],
          ),
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
        MaterialPageRoute(builder: (_) => CourseDetailPage(product: product)),
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
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'DNB Obstetrics & Gynecology',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
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
                      const AppChip('FREE CONTENT'),
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
                const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Text(
                //       '₹ ${product.price.toStringAsFixed(0)}',
                //       style: const TextStyle(
                //         fontSize: 16,
                //         fontWeight: FontWeight.w800,
                //       ),
                //     ),
                //     if (product.hasDiscount) ...[
                //       const SizedBox(width: 8),
                //       Text(
                //         '₹ ${product.originalPrice.toStringAsFixed(0)}',
                //         style: const TextStyle(
                //           color: Colors.black54,
                //           decoration: TextDecoration.lineThrough,
                //           decorationThickness: 2,
                //         ),
                //       ),
                //       const SizedBox(width: 8),
                //       Text(
                //         product.discountLabel,
                //         style: const TextStyle(
                //           color: AppColors.discount,
                //           fontWeight: FontWeight.w600,
                //         ),
                //       ),
                //     ],
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
