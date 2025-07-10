import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onPressed;

  const NotificationIcon({
    super.key,
    required this.unreadCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(icon: const Icon(Icons.notifications), onPressed: onPressed),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
