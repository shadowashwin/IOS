import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../SecureStorage/SecureStorageService.dart';

class PdfViewerPage extends StatefulWidget {
  final String courseId;
  const PdfViewerPage({super.key, required this.courseId});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _localFilePath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    try {
      final storage = SecureStorageService();
      final user = await storage.getUserData();
      final token = user?['token'];
      if (token == null) throw Exception("Token not found");

      // Use 10.0.2.2 for Android emulator, or your machine's LAN IP on device
      final url =
          "https://backend.obgynprep.store/api/courses/${widget.courseId}/pdf";

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode != 200) {
        throw Exception("Failed to load PDF: ${res.statusCode}");
      }

      // The API returns JSON with {"fileName": "...", "data": "<base64>"}
      final Map<String, dynamic> json = jsonDecode(res.body);

      String fileName =
          (json['fileName'] as String?)?.trim() ?? '${widget.courseId}.pdf';
      // ensure it ends with .pdf
      if (!fileName.toLowerCase().endsWith('.pdf')) fileName = '$fileName.pdf';

      String b64 = (json['data'] as String?) ?? '';
      if (b64.isEmpty) throw Exception("Response missing base64 data");

      // In case the API ever sends a data URL like "data:application/pdf;base64,XXXXX"
      final commaIdx = b64.indexOf(',');
      if (b64.startsWith('data:') && commaIdx != -1) {
        b64 = b64.substring(commaIdx + 1);
      }

      final bytes = base64Decode(b64);

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        _localFilePath = file.path;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading PDF: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_localFilePath == null) {
      return const Scaffold(
        body: Center(child: Text("PDF could not be loaded.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Course PDF")),
      body: PDFView(
        filePath: _localFilePath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          debugPrint(error.toString());
        },
        onPageError: (page, error) {
          debugPrint('$page: ${error.toString()}');
        },
      ),
    );
  }
}
