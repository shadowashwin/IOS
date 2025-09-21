import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../Core/Constants/app_colors.dart';
import '../Modal/Product.dart';
import '../SecureStorage/SecureStorageService.dart';

class RazorpayPayButton extends StatefulWidget {
  const RazorpayPayButton({
    super.key,
    required this.product,
    required this.currentPrice, // in rupees
    this.razorpayKey = 'rzp_test_XXXXXXXX', // <-- replace with your key
    this.companyName = 'Miraki Media',
    this.userEmailFallback = 'user@example.com',
  });

  final Product product;
  final String currentPrice; // you had currentPrice as String in your code
  final String razorpayKey;
  final String companyName;
  final String userEmailFallback;

  @override
  State<RazorpayPayButton> createState() => _RazorpayPayButtonState();
}

class _RazorpayPayButtonState extends State<RazorpayPayButton> {
  late final Razorpay _razorpay;
  String? _prefillPhone;
  final String base = "https://horribly-superb-bedbug.ngrok-free.app";

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();
    setState(() => _prefillPhone = (user?['phone'] ?? '').toString());
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _openCheckout() async {
    // guard: zero-price
    final priceRupees = double.tryParse(widget.currentPrice) ?? 0.0;
    if (priceRupees <= 0) return;

    // Razorpay expects amount in *paise* (integer)

    final created = await createOrder(courseId: widget.product.id);
    final amountPaise = (priceRupees * 100).round();

    final options = {
      'key': widget.razorpayKey,
      // 'amount': amountPaise,
      'order_id': created.orderId,
      'amount': created.amountPaise,
      'name': widget.companyName,
      'description': widget.product.title,
      // If you create an order on your server, include: 'order_id': '<server-order-id>',
      'prefill': {
        'contact': _prefillPhone ?? '',
        'email': widget.userEmailFallback,
      },
      'theme': {'color': '#0AA5DE'},
      if (Platform.isAndroid) 'retry': {'enabled': true, 'max_count': 1},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _snack('Failed to open payment: $e', isError: true);
    }
  }

  Future<({String orderId, int amountPaise})> createOrder({
    required String courseId,
  }) async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();
    final token = (user?['token'] ?? '').toString();
    final name = (user?['name'] ?? '').toString();
    final phone = (user?['phone'] ?? '').toString();

    if (token.isEmpty) {
      throw Exception('No token found. Please login again.');
    }

    final uri = Uri.parse('$base/api/payment/checkout');
    final body = {
      "username": name,
      "userMobileNo": phone,
      "courses": [courseId], // your API expects an array
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Checkout failed (${res.statusCode}): ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final order = decoded['order'] as Map<String, dynamic>?;

    if (order == null || order['id'] == null || order['amount'] == null) {
      throw Exception('Invalid server response: missing order fields.');
    }

    final String orderId = order['id'].toString(); // e.g. order_RJzzdjnr2o5MzW
    final int amountPaise = (order['amount'] as num)
        .toInt(); // Razorpay expects paise

    return (orderId: orderId, amountPaise: amountPaise);
  }
  //
  // Future<void> _openCheckout() async {
  //   final priceRupees = double.tryParse(widget.currentPrice) ?? 0.0;
  //   if (priceRupees <= 0) return;
  //
  //   // 1) Create Razorpay order on your server
  //   final created = await createOrder(courseId: widget.product.id);
  //
  //   // 2) Build checkout options — do NOT pass 'amount' or 'currency' when order_id is used
  //   final options = {
  //     'key': widget
  //         .razorpayKey, // must match the key used to create the order on server
  //     'order_id': created.orderId, // <-- only this controls amount/currency
  //     'name': widget.companyName,
  //     'description': widget.product.title,
  //     'notes': {'course_id': widget.product.id},
  //     'prefill': {
  //       'contact': _prefillPhone ?? '',
  //       'email': widget.userEmailFallback,
  //     },
  //     'theme': {'color': '#0AA5DE'},
  //     if (Platform.isAndroid) 'retry': {'enabled': true, 'max_count': 1},
  //   };
  //
  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     _snack('Failed to open payment: $e', isError: true);
  //   }
  // }

  void _handlePaymentSuccess(PaymentSuccessResponse r) {
    // r.paymentId, r.orderId, r.signature
    _snack('Payment Success: ${r.paymentId}');
    // TODO: (recommended) verify payment on your backend using r.orderId/r.paymentId/r.signature
    // You can also mark product as purchased here or navigate to a success screen.
  }

  void _handlePaymentError(PaymentFailureResponse r) {
    _snack('Payment Failed: ${r.code} ${r.message}', isError: true);
  }

  void _handleExternalWallet(ExternalWalletResponse r) {
    _snack('External Wallet: ${r.walletName}');
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFree = widget.currentPrice == "0" || widget.currentPrice == "0.0";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: isFree ? 0 : 10,
        backgroundColor: isFree ? Colors.transparent : AppColors.buyBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: isFree ? null : _openCheckout,
      child: Text(
        isFree ? "" : 'Buy now',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
