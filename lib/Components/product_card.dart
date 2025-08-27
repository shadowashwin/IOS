// import 'package:flutter/material.dart' hide Chip;
//
// import '../Components/Chips.dart';
// import '../Modal/Product.dart';
// import '../main.dart';
//
// class ProductCard extends StatelessWidget {
//   const ProductCard({super.key, required this.product});
//   final Product product;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Thumbnail (green book-like card)
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
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: const [
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
//                 // Right content
//                 Flexible(
//                   flex: 62,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 6,
//                         children: [
//                           Chip(product.badgeLeft),
//                           Chip(product.badgeRight),
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
//                           Text(
//                             product.discountLabel,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: MyApp.kDiscount,
//                             ),
//                           ),
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
//                   backgroundColor: MyApp.kBuyBlue,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {},
//                 child: const Text(
//                   'Buy Now',
//                   style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
                Flexible(
                  flex: 38,
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDE8CC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF9BC69E)),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DNB Obstetrics\n& Gynecology',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.15,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'BY DR MANISHA JAIN',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                          Text(
                            '₹ ${product.originalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            product.discountLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.discount,
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
                  'Buy Now',
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
