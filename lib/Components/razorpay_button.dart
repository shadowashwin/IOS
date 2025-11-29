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
    required this.currentPrice,
    this.razorpayKey = 'rzp_test_XXXXXXXX',
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
  bool _isLoading = false;
  final String base = "https://backend.obgynprep.store";

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

    final String orderId = order['id'].toString();
    print(orderId); // e.g. order_RJzzdjnr2o5MzW
    final int amountPaise = (order['amount'] as num)
        .toInt(); // Razorpay expects paise

    return (orderId: orderId, amountPaise: amountPaise);
  }

  Future<String> fetchRazorpayKey() async {
    try {
      // Replace with your actual backend URL
      final uri = Uri.parse("$base/api/get-key");
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final key = decoded['key']?.toString() ?? '';
        if (key.isEmpty) throw Exception("Key not found in response");
        return key;
      } else {
        throw Exception("Failed to fetch key: ${res.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching Razorpay key: $e");
    }
  }

  Future<void> _openCheckout() async {
    setState(() => _isLoading = true);

    try {
      final created = await createOrder(courseId: widget.product.id);
      final key = await fetchRazorpayKey();

      print("Order ID: ${created.orderId}");
      print("Amount Paise (from server): ${created.amountPaise}");
      print("Razorpay Key: $key");

      final options = {
        'key': key,
        'order_id': created.orderId,
        'amount': created.amountPaise,
        'currency': "INR",
        'name': widget.companyName,
        'description': widget.product.title,
        'notes': {'course_id': widget.product.id},
        'prefill': {
          'contact': _prefillPhone ?? '',
          'email': widget.userEmailFallback,
        },
        'theme': {'color': '#0AA5DE'},
        if (Platform.isAndroid) 'retry': {'enabled': true, 'max_count': 1},
      };

      _razorpay.open(options);
    } catch (e) {
      _snack('Failed to open payment: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyPaymentOnServer({
    required String orderId,
    required String paymentId,
    required String signature,
    required String courseId, // optional but handy to grant access
  }) async {
    final storage = SecureStorageService();
    final user = await storage.getUserData();
    final token = (user?['token'] ?? '').toString();

    final uri = Uri.parse('$base/api/payment/verification');

    final payload = {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
      // include any app context you need on the backend
      'course_id': courseId,
    };

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('Verification failed (${res.statusCode}): ${res.body}');
    }

    // Optionally parse your API response
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final success = decoded['success'] == true;

    if (!success) {
      throw Exception('Server reported verification failure');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse r) async {
    try {
      // r.paymentId, r.orderId, r.signature come from the Razorpay Flutter plugin
      await _verifyPaymentOnServer(
        orderId: r.orderId!,
        paymentId: r.paymentId!,
        signature: r.signature!, // null-safety: plugin provides it on success
        courseId: widget.product.id, // so backend can grant access
      );

      _snack('Payment verified ✓');
      // TODO: unlock course / navigate to success page, etc.
    } catch (e) {
      _snack('Payment success but verification failed: $e', isError: true);
      // (Optional) navigate to a “pending verification” screen
    }
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

  Future<void> _handleCheckout() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _openCheckout(); // your existing method
    } catch (e) {
      _snack('Failed to open payment: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      // Disable when free OR loading
      onPressed: (isFree || _isLoading) ? null : _handleCheckout,
      child: isFree
          ? const SizedBox.shrink()
          : _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Buy now',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
    );
  }
}
