import 'package:flutter/material.dart';

class SnackBarHelper {
  static void showStyledSnackBar(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
    final color = isSuccess ? Colors.green.shade600 : Colors.red.shade700;
    final icon = isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
