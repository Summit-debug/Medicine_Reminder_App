import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const String channelId = 'med_channel';

  static Future<void> initialize() async {
    if (kIsWeb) return; // notifications not supported on web via this plugin
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    tz.initializeTimeZones();
    await _plugin.initialize(settings);
  }

  static Future<void> scheduleMultipleDaily({
    required int baseId,
    required String title,
    required String body,
    required List<String> times, // ['08:00','20:00']
  }) async {
    if (kIsWeb) return;
    int idx = 0;
    for (final t in times) {
      final parts = t.split(':');
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

      final id = baseId * 100 + idx;
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(channelId, 'Medicine Reminders',
              channelDescription: 'Reminders for medicines', importance: Importance.max, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      idx++;
    }
  }

  static Future<void> cancelByBaseId(int baseId, int timesCount) async {
    if (kIsWeb) return;
    for (int i = 0; i < timesCount; i++) {
      final id = baseId * 100 + i;
      await _plugin.cancel(id);
    }
  }

  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
