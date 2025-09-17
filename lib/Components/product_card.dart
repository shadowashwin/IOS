// import 'package:flutter/material.dart';
//
// import '../../core/constants/app_colors.dart';
// import '../Modal/Product.dart';
// import '../Screens/course_detail_screen.dart';
// import 'Chips.dart';
//
// class ProductCard extends StatelessWidget {
//   const ProductCard({super.key, required this.product});
//   final Product product;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: _box,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Flexible(
//                   flex: 38,
//                   child: AspectRatio(
//                     aspectRatio: 16 / 10,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFCDE8CC),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: const Color(0xFF9BC69E)),
//                       ),
//                       padding: const EdgeInsets.all(8),
//                       child: const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'DNB Obstetrics\n& Gynecology',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w800,
//                               fontSize: 12,
//                               color: Colors.black87,
//                               height: 1.15,
//                             ),
//                           ),
//                           Spacer(),
//                           Text(
//                             'BY DR MANISHA JAIN',
//                             style: TextStyle(
//                               fontSize: 9,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Flexible(
//                   flex: 62,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 6,
//                         children: [
//                           AppChip(product.badgeLeft),
//                           AppChip(product.badgeRight),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         product.title,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Text(
//                             '₹ ${product.price.toStringAsFixed(0)}',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             '₹ ${product.originalPrice.toStringAsFixed(0)}',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black54,
//                               decoration: TextDecoration.lineThrough,
//                               decorationThickness: 2,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               height: 44,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.buyBlue,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => CourseDetailPage(product: product),
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   'View Details & Buy',
//                   style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   BoxDecoration get _box => BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(12),
//     boxShadow: [
//       BoxShadow(
//         color: Colors.black.withOpacity(0.05),
//         blurRadius: 8,
//         offset: const Offset(0, 2),
//       ),
//     ],
//   );
// }
// Widgets/ProductCard.dart
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../Modal/Product.dart';
import '../Screens/course_detail_screen.dart';
import 'Chips.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _box,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: thumbnail / placeholder
                Flexible(
                  flex: 38,
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: _LeftThumb(product: product),
                  ),
                ),
                const SizedBox(width: 12),

                // RIGHT: chips, title, price
                Flexible(
                  flex: 62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          AppChip(product.badgeLeft),
                          AppChip(product.badgeRight),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '₹ ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (product.hasDiscount)
                            Text(
                              '₹ ${product.originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 2,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buyBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailPage(product: product),
                    ),
                  );
                },
                child: const Text(
                  'View Details & Buy',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration get _box => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

class _LeftThumb extends StatelessWidget {
  const _LeftThumb({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    // If you have image from API, show it
    if (product.images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.images.first,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    // else placeholder like screenshot
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCDE8CC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF9BC69E)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Use first bullet (if any) to mimic the badge text,
          // otherwise take a shortened course title
          Text(
            (product.bullets.isNotEmpty ? product.bullets.first : product.title)
                .toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.black87,
              height: 1.15,
            ),
          ),
          // const Spacer(),
          // Text(
          //   (product.description ?? '').isEmpty
          //       ? 'COURSE'
          //       : (product.description!.length > 26
          //             ? '${product.description!.substring(0, 26).toUpperCase()}…'
          //             : product.description!.toUpperCase()),
          //   style: const TextStyle(fontSize: 9, color: Colors.black87),
          // ),
        ],
      ),
    );
  }
}
