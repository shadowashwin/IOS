import 'package:flutter/material.dart';

Widget buildTextField(
  TextEditingController ctrl,
  String label,
  IconData icon, {
  TextInputType keyboard = TextInputType.text,
  int? maxLen,
}) {
  return TextField(
    controller: ctrl,
    keyboardType: keyboard,
    maxLength: maxLen,
    decoration: InputDecoration(
      counterText: '',
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
    ),
  );
}
