import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // bool signup_login = true;

  final _orgController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  String apiBaseUrl = "https://backend.obgynprep.store";

  // String apiBaseUrl = "https://8c87f6c5791d.ngrok-free.app";

  int _resendCooldown = 0;
  Timer? _resendTimer;

  // 🔥 LOADING FLAGS
  bool _isLoadingOrg = false;
  bool _isLoadingRegister = false;
  bool _isLoadingOtpVerify = false;

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
    _otpFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<bool> _verifyOtpLocal(String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return otp.length == 6;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
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

      final storage = SecureStorageService();
      await storage.saveUserData(data);

      return data;
    } else {
      throw Exception("Failed to verify OTP: ${res.statusCode} - ${res.body}");
    }
  }

  // 🔥 VERIFY ORG BUTTON HANDLER WITH LOADING
  Future<void> _onOrgSubmit() async {
    if (_isLoadingOrg) return;
    setState(() => _isLoadingOrg = true);

    final code = _orgController.text.trim();
    if (code.isEmpty) {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Please enter an org code',
      );
      setState(() => _isLoadingOrg = false);
      return;
    }

    try {
      final uri = Uri.parse('$apiBaseUrl/api/users/validate-org-code');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orgCode': code}),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final isValid = data['valid'] == true;
        if (isValid) {
          setState(() => _stage = _Stage.register);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('orgCode', code);
        } else {
          _showBottomMessage(
            icon: Icons.error_outline,
            color: Colors.red,
            text: 'Invalid org code',
          );
        }
      } else {
        print(resp.body);
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
    } finally {
      setState(() => _isLoadingOrg = false);
    }
  }

  // 🔥 SEND OTP BUTTON HANDLER WITH LOADING
  void _onRegisterSubmit() async {
    if (_isLoadingRegister) return;
    setState(() => _isLoadingRegister = true);

    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();

    // if ((!signup_login && mobile.isEmpty) ||
    //     (signup_login && (name.isEmpty || mobile.isEmpty))) {
    //   _showBottomMessage(
    //     icon: Icons.error_outline,
    //     color: Colors.red,
    //     text: 'Please enter all details',
    //   );
    //   setState(() => _isLoadingRegister = false);
    //   return;
    // }

    try {
      // final uri = signup_login
      //     ? Uri.parse('$apiBaseUrl/api/users/register-send-otp')
      //     : Uri.parse('$apiBaseUrl/api/users/login-send-otp');

      // final resp = await http.post(
      //   uri,
      //   headers: {'Content-Type': 'application/json'},
      //   body: signup_login
      //       ? jsonEncode({'name': name, 'phone': mobile})
      //       : jsonEncode({'phone': mobile}),
      // );

      final uri = Uri.parse('$apiBaseUrl/api/users/login-send-otp');

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': mobile}),
      );

      if (resp.statusCode == 200) {
        setState(() => _stage = _Stage.otp);
        _startResendCooldown();
      } else {
        print(resp.body);
        _showBottomMessage(
          icon: Icons.error_outline,
          color: Colors.red,
          text: 'User already exists or invalid credentials',
        );
      }
    } catch (e) {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Network error: $e',
      );
    } finally {
      setState(() => _isLoadingRegister = false);
    }
  }

  // 🔥 OTP SUBMIT WITH LOADING
  void _onOtpSubmit() async {
    if (_isLoadingOtpVerify) return;
    setState(() => _isLoadingOtpVerify = true);

    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _isLoadingOtpVerify = false);
      return;
    }

    final ok = await _verifyOtpLocal(otp);
    if (!ok) {
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Invalid OTP, try again',
      );
      setState(() => _isLoadingOtpVerify = false);
      return;
    }

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
      _showBottomMessage(
        icon: Icons.error_outline,
        color: Colors.red,
        text: 'Verification failed',
      );
    } finally {
      setState(() => _isLoadingOtpVerify = false);
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
            buildButton(
              _isLoadingOrg ? "Please wait..." : "Verify Org Code",
              _isLoadingOrg ? null : _onOrgSubmit,
              loading: _isLoadingOrg,
            ),
          ],
        );
        break;

      // case _Stage.register:
      //   content = Column(
      //     children: [
      //       signup_login
      //           ? buildTextField(_nameController, 'Full Name', Icons.person)
      //           : Container(),
      //       const SizedBox(height: 16),
      //       buildTextField(
      //         _mobileController,
      //         'Mobile Number',
      //         Icons.phone,
      //         keyboard: TextInputType.phone,
      //       ),
      //       const SizedBox(height: 24),
      //       buildButton(
      //         _isLoadingRegister ? "Please wait..." : "Send OTP",
      //         _isLoadingRegister ? null : _onRegisterSubmit,
      //         loading: _isLoadingRegister,
      //       ),
      //     ],
      //   );
      // break;

      case _Stage.register:
        content = Column(
          children: [
            buildTextField(
              _mobileController,
              'Mobile Number',
              Icons.phone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            buildButton(
              _isLoadingRegister ? "Please wait..." : "Send OTP",
              _isLoadingRegister ? null : _onRegisterSubmit,
              loading: _isLoadingRegister,
            ),
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
              onCompleted: (_) => _onOtpSubmit(),
            ),
            const SizedBox(height: 24),

            if (_isLoadingOtpVerify)
              const Center(child: CircularProgressIndicator()),

            if (_resendCooldown > 0)
              Text(
                'Resend available in ${_resendCooldown.toString().padLeft(2, '0')}s',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 8),

            buildButton(
              'Resend OTP',
              (_isResendDisabled || _isLoadingOtpVerify)
                  ? null
                  : () {
                      _onRegisterSubmit();
                      _startResendCooldown();
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
                        _stage == _Stage.org
                            ? const Text(
                                "Welcome !",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SizedBox(
                                height: mq.height * 0.05,
                                width: mq.width * 0.7,
                                child: Row(
                                  children: [
                                    // InkWell(
                                    //   onTap: () =>
                                    //       setState(() => signup_login = true),
                                    //   child: Container(
                                    //     height: mq.height * 0.05,
                                    //     width: mq.width * 0.35,
                                    //     decoration: BoxDecoration(
                                    //       color: signup_login
                                    //           ? Colors.blue
                                    //           : Colors.white,
                                    //       borderRadius: BorderRadius.circular(
                                    //         10,
                                    //       ),
                                    //     ),
                                    //     child: Center(
                                    //       child: Text(
                                    //         "Signup",
                                    //         style: TextStyle(
                                    //           color: signup_login
                                    //               ? Colors.white
                                    //               : Colors.blue,
                                    //           fontWeight: FontWeight.bold,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    // InkWell(
                                    //   onTap: () =>
                                    //       setState(() => signup_login = false),
                                    //   child: Container(
                                    //     height: mq.height * 0.05,
                                    //     width: mq.width * 0.35,
                                    //     decoration: BoxDecoration(
                                    //       color: signup_login
                                    //           ? Colors.white
                                    //           : Colors.blue,
                                    //       borderRadius: BorderRadius.circular(
                                    //         10,
                                    //       ),
                                    //     ),
                                    //     child: Center(
                                    //       child: Text(
                                    //         "Login",
                                    //         style: TextStyle(
                                    //           color: signup_login
                                    //               ? Colors.blue
                                    //               : Colors.white,
                                    //           fontWeight: FontWeight.bold,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                        // SizedBox(
                        //   height: mq.height * (signup_login ? 0.02 : 0.089),
                        // ),
                        const SizedBox(height: 16),
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
