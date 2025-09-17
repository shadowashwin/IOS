import 'package:flutter/material.dart';

enum BottomMessageType { success, error, info, warning }

class BottomMessage {
  // Quick presets (optional)
  static IconData _icon(BottomMessageType t) => switch (t) {
    BottomMessageType.success => Icons.check_circle,
    BottomMessageType.error => Icons.error_rounded,
    BottomMessageType.info => Icons.info_rounded,
    BottomMessageType.warning => Icons.warning_amber_rounded,
  };

  static Color _color(BottomMessageType t, BuildContext c) => switch (t) {
    BottomMessageType.success => Colors.green,
    BottomMessageType.error => Colors.red,
    BottomMessageType.info => Theme.of(c).colorScheme.primary,
    BottomMessageType.warning => Colors.orange,
  };

  /// Call this from anywhere:
  /// BottomMessage.show(context, text: 'Saved!');
  static Future<T?> show<T>(
    BuildContext context, {
    required String text,
    IconData? icon,
    Color? color,
    String okText = 'OK',
    VoidCallback? onOk,
    bool isDismissible = true,
    Duration? autoCloseAfter, // e.g., const Duration(seconds: 2)
    BottomMessageType? type, // use preset icon/color if provided
  }) async {
    final iconData = icon ?? _icon(type ?? BottomMessageType.info);
    final tint = color ?? _color(type ?? BottomMessageType.info, context);

    final controller = showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomMessageContent(
        icon: iconData,
        color: tint,
        text: text,
        okText: okText,
        onOk: onOk,
      ),
    );

    if (autoCloseAfter != null) {
      Future.delayed(autoCloseAfter, () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    return controller;
  }
}

class _BottomMessageContent extends StatelessWidget {
  const _BottomMessageContent({
    required this.icon,
    required this.color,
    required this.text,
    required this.okText,
    this.onOk,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String okText;
  final VoidCallback? onOk;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onOk?.call();
            },
            child: Text(okText),
          ),
        ],
      ),
    );
  }
}

// import 'package:your_app/ui/widgets/bottom_message.dart';
//
// // Basic
// BottomMessage.show(
// context,
// text: 'Logged out successfully',
// type: BottomMessageType.success,
// );
//
// // Custom color/icon
// BottomMessage.show(
// context,
// text: 'Something went wrong',
// icon: Icons.error_outline,
// color: Colors.redAccent,
// );
//
// // Auto close after 2 seconds, no button press needed
// BottomMessage.show(
// context,
// text: 'Saved!',
// type: BottomMessageType.success,
// autoCloseAfter: const Duration(seconds: 2),
// );
