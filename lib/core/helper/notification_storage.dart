import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationStorage {
  static const _listKey = 'notif_items';
  static const _seenKey = 'notif_seen_at'; // epoch ms

  // batas maksimal item tersimpan
  static const int _maxItems = 50;

  // auto hapus notif yang lebih lama dari ini
  static const Duration _ttl = Duration(days: 30);

  /// Simpan notif baru (dipakai saat FCM masuk)
  static Future<void> push({
    required String title,
    required String message,
    String type = 'general', // reminder_checkin, reminder_checkout, permission, system, general
    DateTime? createdAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_listKey) ?? [];

    final now = createdAt ?? DateTime.now();
    final item = {
      'title': title,
      'message': message,
      'type': type,
      'createdAt': now.toIso8601String(),
    };

    // paling atas biar terbaru dulu
    list.insert(0, jsonEncode(item));

    // ✅ batasi jumlah notif
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }

    await prefs.setStringList(_listKey, list);
  }

  /// Tandai semua notif sebagai sudah dilihat (dipanggil saat keluar dari NotificationPage)
  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seenKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<int> seenAtMs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_seenKey) ?? 0;
  }

  /// Hapus semua notif (opsional dipakai nanti)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_listKey);
  }

  static Future<List<NotifVM>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_listKey) ?? [];
    final seenAt = await seenAtMs();

    // ✅ auto filter notif yang sudah lewat TTL
    final cutoff = DateTime.now().subtract(_ttl);

    final keptRaw = <String>[];
    final result = <NotifVM>[];

    for (final raw in rawList) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final createdAt =
            DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now();

        // buang notif yang terlalu lama
        if (createdAt.isBefore(cutoff)) continue;

        keptRaw.add(raw);

        final type = (m['type'] ?? 'general') as String;

        result.add(
          NotifVM(
            title: (m['title'] ?? 'Notifikasi') as String,
            message: (m['message'] ?? '') as String,
            time: _humanTime(createdAt),
            isUnread: createdAt.millisecondsSinceEpoch > seenAt,
            icon: _iconByType(type),
          ),
        );
      } catch (_) {
        // kalau ada data rusak, skip aja
      }
    }

    // kalau ada yang terfilter, simpan ulang biar storage bersih
    if (keptRaw.length != rawList.length) {
      await prefs.setStringList(_listKey, keptRaw);
    }

    return result;
  }

  static String _humanTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24 && now.day == dt.day) {
      return 'Hari ini • ${DateFormat('HH:mm').format(dt)}';
    }
    if (diff.inHours < 48 &&
        (now.subtract(const Duration(days: 1)).day == dt.day)) {
      return 'Kemarin • ${DateFormat('HH:mm').format(dt)}';
    }
    return DateFormat('dd MMM yyyy • HH:mm').format(dt);
  }

  static IconData _iconByType(String type) {
    switch (type) {
      case 'reminder_checkin':
      case 'reminder_checkout':
        return Icons.notifications_active_outlined;
      case 'permission':
        return Icons.assignment_turned_in_outlined;
      case 'system':
        return Icons.system_update_alt_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  static Future<int> unreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_listKey) ?? [];
    final seenAt = await seenAtMs();
  
    int count = 0;

    for (final raw in rawList) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final createdAt =
            DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now();

        // kalau kamu pakai TTL, biarkan sesuai getAll (optional)
        final cutoff = DateTime.now().subtract(_ttl);
          if (createdAt.isBefore(cutoff)) continue;

          if (createdAt.millisecondsSinceEpoch > seenAt) {
            count++;
          }
        } catch (_) {
          // skip data rusak
        }
      }
    return count;
  }
}

class NotifVM {
  final String title;
  final String message;
  final String time;
  final bool isUnread;
  final IconData icon;

  NotifVM({
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
    required this.icon,
  });
}
