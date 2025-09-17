import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

import '../Components/BuildButton.dart';
import '../Components/BuildTextfield.dart';
import '../SecureStorage/SecureStorageService.dart';
import 'home_screen.dart';

enum _Stage { org, register, otp }

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  _Stage _stage = _Stage.org;
  final _orgController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  String apiBaseUrl = "https://horribly-superb-bedbug.ngrok-free.app";

  int _resendCooldown = 0;
  String server_otp = "";
  Timer? _resendTimer;

  bool get _isResendDisabled => _resendCooldown > 0;

  void _startResendCooldown([int seconds = 30]) {
    _resendTimer?.cancel();
    setState(() => _resendCooldown = seconds);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        t.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  @override
  void dispose() {
    _orgController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose(); // ← dispose focus node
    super.dispose();
  }

  Future<bool> _verifyOtp(String otp) async {
    // pretend verifying OTP via API
    await Future.delayed(const Duration(milliseconds: 500));
    return otp == server_otp && server_otp.length == 6; // demo only
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    bool androidEmulator = false,
  }) async {
    final uri = Uri.parse("$apiBaseUrl/api/users/verify-otp");

    final res = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {"phone": phone, "otp": otp},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      // Save full response to secure storage
      final storage = SecureStorageService();
      await storage.saveUserData(data);

      return data;
    } else {
      throw Exception("Failed to verify OTP: ${res.statusCode} - ${res.body}");
    }
  }

  Future<void> _onOrgSubmit() async {
    final code = _orgController.text.trim();
    if (code.isEmpty) {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Please enter an org code',
      );
      return;
    }

    // Optional: show loading state in your UI if you track one
    // setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('${apiBaseUrl}/api/users/validate-org-code');
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'orgCode': code}),
          )
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final isValid = data['valid'] == true;

        if (isValid) {
          setState(() => _stage = _Stage.register);
        } else {
          _showBottomMessage(
            icon: Icons.error_outline,
            color: Colors.red,
            text: 'Invalid org code',
          );
        }
      } else {
        _showBottomMessage(
          icon: Icons.error_outline,
          color: Colors.red,
          text: 'Server error (${resp.statusCode})',
        );
      }
    } on TimeoutException {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Request timed out. Check your connection.',
      );
    } catch (e) {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Network error: $e',
      );
    } finally {
      // Optional:
      // setState(() => _isLoading = false);
    }
  }

  Future<String?> fetchOtp(String phoneNumber) async {
    // NOTE: Use http://10.0.2.2:5000 if testing on Android Emulator
    final url = Uri.parse('$apiBaseUrl/api/users/dev/get-otp/$phoneNumber');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // If server responds like { "otp": "378378" }
      if (data is Map && data.containsKey('otp')) {
        return data['otp'].toString();
      }
      throw Exception('OTP field not found in response: $data');
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  void _onRegisterSubmit() async {
    final name = _nameController.text.trim();
    // final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();
    // || email.isEmpty
    if (name.isEmpty || mobile.isEmpty) {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Please enter all details',
      );
      return;
    }

    // await _createTempUser();
    try {
      print("registering");
      final uri = Uri.parse('$apiBaseUrl/api/users/register-send-otp');
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name, 'phone': mobile}),
          )
          .timeout(const Duration(seconds: 8));
      print(resp.body);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final isValid = data['message'] == "otp sent";

        if (isValid) {
          setState(() => _stage = _Stage.otp);
          final otp = await fetchOtp(mobile);
          print(otp);
          setState(() {
            server_otp = otp!;
          });
        } else {
          _showBottomMessage(
            icon: Icons.error_outline,
            color: Colors.red,
            text: 'Invalid cred',
          );
        }
      } else {
        _showBottomMessage(
          icon: Icons.error_outline,
          color: Colors.red,
          text: 'Server error (${resp.statusCode})',
        );
      }
    } catch (e) {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Network error: $e',
      );
    }
  }

  void _onOtpSubmit() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;
    final ok = await _verifyOtp(otp);
    if (ok) {
      try {
        final response = await verifyOtp(
          phone: _mobileController.text.trim(),
          otp: otp,
        );

        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
        print("Name: ${response['name']}");
        print("Token: ${response['token']}");
      } catch (e) {
        print("❌ Error: $e");
      }
    } else {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Invalid OTP, try again',
      );
    }
  }

  void _showBottomMessage({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _goToOtpStage() {
    setState(() => _stage = _Stage.otp);
    _startResendCooldown(); // kicks off 30s countdown immediately
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    Widget content;
    switch (_stage) {
      case _Stage.org:
        content = Column(
          children: [
            buildTextField(_orgController, 'Organization Code', Icons.business),
            const SizedBox(height: 24),
            buildButton('Verify Org Code', _onOrgSubmit),
          ],
        );
        break;

      case _Stage.register:
        content = Column(
          children: [
            buildTextField(_nameController, 'Full Name', Icons.person),
            const SizedBox(height: 16),
            // buildTextField(_emailController, 'Email Address', Icons.email),
            // const SizedBox(height: 16),
            buildTextField(
              _mobileController,
              'Mobile Number',
              Icons.phone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            buildButton('Send OTP', _onRegisterSubmit),
          ],
        );
        break;

      case _Stage.otp:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Pinput(
              length: 6,
              controller: _otpController,
              focusNode: _otpFocusNode,
              pinAnimationType: PinAnimationType.fade,
              defaultPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
              ),
              onCompleted: (pin) => _onOtpSubmit(),
            ),
            const SizedBox(height: 24),

            if (_resendCooldown > 0)
              Text(
                'Resend available in ${_resendCooldown.toString().padLeft(2, '0')}s',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 8),

            buildButton(
              'Resend OTP',
              _isResendDisabled
                  ? null
                  : () {
                      _onRegisterSubmit(); // your resend logic
                      _startResendCooldown(); // disable again for 30s
                    },
            ),
          ],
        );
        break;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white70],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.jpeg',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: mq.width * 0.95,
                  height: mq.height * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade600,
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 5),
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _stage == _Stage.org ? "Welcome !" : "Login",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox.fromSize(
                          size: Size.fromHeight(mq.height * 0.02),
                        ),
                        content,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
