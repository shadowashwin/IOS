import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../Modal/Product.dart';

class PricingDetailsCard extends StatelessWidget {
  const PricingDetailsCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return product.originalPrice == 0.0
        ? Container()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.white,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                title: Row(
                  children: [
                    const Text(
                      'Pricing Details',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      'You Pay  ₹ ${product.price}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                children: [
                  PriceLine('Course Price', '₹ ${product.originalPrice}'),
                  PriceLine('Internet Handling Charges', '₹ 137'),
                  PriceLine('G.S.T. (18%)', '₹ 763'),
                  PriceLine('Platform Fee', '₹ 20', strikeOld: '₹ 40'),
                  PriceLine('Discount 28.57%', '- ₹ 2,000', isDiscount: true),
                  SizedBox(height: 8),
                  // HintLine('Purchasing in Madhya Pradesh'),
                  // SizedBox(height: 8),
                  TermsLine(),
                ],
              ),
            ),
          );
  }
}

class PriceLine extends StatelessWidget {
  const PriceLine(
    this.label,
    this.value, {
    super.key,
    this.isDiscount = false,
    this.strikeOld,
  });
  final String label;
  final String value;
  final bool isDiscount;
  final String? strikeOld;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDiscount ? AppColors.discount : Colors.black87,
              ),
            ),
          ),
          if (strikeOld != null)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Text(
                strikeOld!,
                style: const TextStyle(
                  color: Colors.black54,
                  decoration: TextDecoration.lineThrough,
                  decorationThickness: 2,
                ),
              ),
            ),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? AppColors.discount : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class HintLine extends StatelessWidget {
  const HintLine(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.location_on_outlined, size: 18, color: Colors.black54),
        SizedBox(width: 6),
        Text(
          'Purchasing in Madhya Pradesh',
          style: TextStyle(color: Colors.black87),
        ),
      ],
    );
  }
}

class TermsLine extends StatelessWidget {
  const TermsLine({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '* Amount payable is inclusive of taxes. Terms & Conditions apply.',
      style: TextStyle(fontSize: 12, color: Colors.black54),
    );
  }
}
