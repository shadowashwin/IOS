import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  Future<void> openWhatsApp({
    required String phone,
    String message = "",
  }) async {
    final url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not open WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            openWhatsApp(
              phone: "919407363827", // phone with country code, no + or 0
              message: "Hello, I need help regarding the product.",
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/whatsapp_logo.webp',
                fit: BoxFit.cover,
                height: 70,
              ),
              Text(
                "TAP TO CHAT",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
