// import 'package:flutter/material.dart';
//
// Widget buildButton(String text, VoidCallback? onPressed) {
//   return SizedBox(
//     width: double.infinity,
//     child: ElevatedButton(
//       onPressed: onPressed, // null => disabled
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         backgroundColor: Colors.blue,
//         disabledBackgroundColor: Colors.grey.shade400,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 16, color: Colors.white),
//       ),
//     ),
//   );
// }

import 'package:flutter/material.dart';

Widget buildButton(
  String text,
  VoidCallback? onPressed, {
  bool loading = false,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      // disable when loading
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        disabledBackgroundColor: Colors.grey.shade400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
    ),
  );
}
