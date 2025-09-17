import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../Modal/Product.dart';

class StickyBuyBar extends StatelessWidget {
  const StickyBuyBar({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final currentPrice = product.price.toStringAsFixed(0);
    final oldPrice = product.hasDiscount
        ? product.originalPrice.toStringAsFixed(0)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: currentPrice == "0" ? Colors.transparent : Colors.white,
        boxShadow: [
          BoxShadow(
            color: currentPrice == "0"
                ? Colors.transparent
                : Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentPrice == "0" ? "" : '₹ $currentPrice',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                // if (oldPrice != null)
                //   BottomStrikeRow(
                //     oldPrice: oldPrice,
                //     discountLabel: product.discountLabel.isEmpty
                //         ? null
                //         : product.discountLabel,
                //   ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: currentPrice == "0" ? 0 : 10,
                backgroundColor: currentPrice == "0"
                    ? Colors.transparent
                    : AppColors.buyBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: Text(
                currentPrice == "0" ? "" : 'Buy now',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomStrikeRow extends StatelessWidget {
  const BottomStrikeRow({
    super.key,
    required this.oldPrice,
    this.discountLabel,
  });
  final String oldPrice;
  final String? discountLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '₹ $oldPrice',
          style: const TextStyle(
            color: Colors.black54,
            decoration: TextDecoration.lineThrough,
            decorationThickness: 2,
          ),
        ),
        if (discountLabel != null && discountLabel!.trim().isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(
            discountLabel!,
            style: const TextStyle(
              color: AppColors.discount,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
