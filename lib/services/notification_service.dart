import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _setupNotificationStream();
  }

  void _setupNotificationStream() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _showNotification(change.doc.data() as Map<String, dynamic>);
        }
      }
    });
  }

  Future<void> _showNotification(Map<String, dynamic> notificationData) async {
    const androidDetails = AndroidNotificationDetails(
      'meeting_channel',
      'Meeting Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notificationData.hashCode,
      notificationData['title'],
      notificationData['message'],
      details,
    );
  }

  Future<void> scheduleMeetingReminder(String meetingId, String title, DateTime scheduledFor) async {
    final scheduledDate = tz.TZDateTime.from(scheduledFor, tz.local);
    final reminderTime = scheduledDate.subtract(Duration(minutes: 15));

    const androidDetails = AndroidNotificationDetails(
      'meeting_reminder_channel',
      'Meeting Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      meetingId.hashCode,
      'Meeting Reminder',
      'Your meeting "$title" starts in 15 minutes',
      reminderTime,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
} 