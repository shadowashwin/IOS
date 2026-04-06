import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Screens/LoginScreen.dart';
import '../SecureStorage/SecureStorageService.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  @override
  State<DeleteConfirmationDialog> createState() =>
      DeleteConfirmationDialogState();
}

class DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  int secondsLeft = 10;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      if (secondsLeft == 1) {
        setState(() {
          secondsLeft = 0;
          isButtonEnabled = true;
        });
        return false;
      }

      setState(() {
        secondsLeft--;
      });

      return true;
    });
  }

  Future<void> deleteAccountAndLogout(BuildContext context) async {
    // const String url = 'https://backend.obgynprep.store/api/users/delete';
    const String url = "https://3ae4-2001-4490-4465-3f19-2dce-8b0e-c6-29ae.ngrok-free.app/api/users/delete";

    // final storage = SecureStorageService();

    try {
      final storage = SecureStorageService();
      final user = await storage.getUserData();

      if (user == null || user['token'] == null) {
        throw Exception("No user logged in or token missing.");
      }

      final token = user['token'];

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // ✅ Clear secure storage
        await storage.clearAll();

        // ✅ OPTIONAL: Clear any global in-memory data here
        // Example:
        // userProvider.clear();
        // appState.reset();

        // ✅ Navigate to LoginScreen & remove all routes
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => Loginscreen()),
            (route) => false,
          );
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Delete failed');
      }
    } catch (e) {
      debugPrint('Delete account error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete account. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "DELETE ACCOUNT",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        "Are you sure? Because this process is irreversible.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isButtonEnabled
              ? () async {
                  await deleteAccountAndLogout(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isButtonEnabled ? Colors.red : Colors.grey,
          ),
          child: Text(
            isButtonEnabled ? "OK" : "OK (${secondsLeft}s)",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
