import 'package:flutter/material.dart';

class StageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> dates;
  final int currentIndex;
  final Function(int) onDateChanged;
  final String stage;

  const StageAppBar({
    super.key,
    required this.dates,
    required this.currentIndex,
    required this.onDateChanged,
    required this.stage,
  });

  void _changeDate(bool next) {
    final newIndex = next ? currentIndex + 1 : currentIndex - 1;
    if (newIndex >= 0 && newIndex < dates.length) {
      onDateChanged(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(stage),
      centerTitle: true,
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: currentIndex > 0 ? () => _changeDate(false) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                dates[currentIndex],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed:
                    currentIndex < dates.length - 1
                        ? () => _changeDate(true)
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
