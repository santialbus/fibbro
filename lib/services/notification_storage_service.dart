import 'package:shared_preferences/shared_preferences.dart';

class NotificationStorageService {
  static const _unreadKey = 'unread_notifications';

  Future<List<String>> getUnreadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unreadKey) ?? [];
  }

  Future<void> addUnread(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_unreadKey) ?? [];
    if (!current.contains(id)) {
      current.add(id);
      await prefs.setStringList(_unreadKey, current);
    }
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unreadKey, []);
  }

  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_unreadKey)?.length ?? 0;
  }

  Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_unreadKey) ?? [];
    if (current.contains(id)) {
      current.remove(id);
      await prefs.setStringList(_unreadKey, current);
    }
  }
}
