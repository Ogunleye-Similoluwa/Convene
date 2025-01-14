import 'package:convene/widgets/animated_list_item.dart';
import 'package:convene/widgets/animated_ripple_card.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import '../services/animation_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  @override
  _NotificationPreferencesScreenState createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> 
    with SingleTickerProviderStateMixin {
  final _prefs = SharedPreferences.getInstance();
  bool meetingReminders = true;
  bool emailNotifications = true;
  int reminderTime = 15; // minutes
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _loadPreferences();
    _controller.forward();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _prefs;
    setState(() {
      meetingReminders = prefs.getBool('meeting_reminders') ?? true;
      emailNotifications = prefs.getBool('email_notifications') ?? true;
      reminderTime = prefs.getInt('reminder_time') ?? 15;
      soundEnabled = prefs.getBool('sound_enabled') ?? true;
      vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await _prefs;
    await prefs.setBool('meeting_reminders', meetingReminders);
    await prefs.setBool('email_notifications', emailNotifications);
    await prefs.setInt('reminder_time', reminderTime);
    await prefs.setBool('sound_enabled', soundEnabled);
    await prefs.setBool('vibration_enabled', vibrationEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Notification Preferences'),
        elevation: 0,
      ),
      body: AnimationService.fadeInTransition(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSection(
              title: 'Meeting Notifications',
              children: [
                _buildSwitchTile(
                  title: 'Meeting Reminders',
                  subtitle: 'Get notified before meetings',
                  value: meetingReminders,
                  onChanged: (value) {
                    setState(() => meetingReminders = value);
                    _savePreferences();
                  },
                ),
                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive meeting invites via email',
                  value: emailNotifications,
                  onChanged: (value) {
                    setState(() => emailNotifications = value);
                    _savePreferences();
                  },
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildSection(
              title: 'Reminder Settings',
              children: [
                _buildDropdownTile(
                  title: 'Reminder Time',
                  value: reminderTime,
                  items: [5, 10, 15, 30, 60],
                  onChanged: (value) {
                    setState(() => reminderTime = value!);
                    _savePreferences();
                  },
                ),
                _buildSwitchTile(
                  title: 'Sound',
                  subtitle: 'Play sound for notifications',
                  value: soundEnabled,
                  onChanged: (value) {
                    setState(() => soundEnabled = value);
                    _savePreferences();
                  },
                ),
                _buildSwitchTile(
                  title: 'Vibration',
                  subtitle: 'Vibrate for notifications',
                  value: vibrationEnabled,
                  onChanged: (value) {
                    setState(() => vibrationEnabled = value);
                    _savePreferences();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return AnimatedListItem(
      index: title == 'Meeting Notifications' ? 0 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: children.map((child) => AnimatedRippleCard(
                onTap: () {
                  if (child is SwitchListTile) {
                    child.onChanged?.call(!child.value);
                  }
                },
                child: child,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: textColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: buttonColor,
        secondary: Icon(
          value ? Icons.notifications_active : Icons.notifications_off,
          color: value ? buttonColor : textColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: textColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer,
            color: buttonColor,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Time before meeting start',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<int>(
            value: value,
            items: items.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  '$value minutes',
                  style: TextStyle(color: textColor),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: secondaryBackgroundColor,
            icon: Icon(Icons.arrow_drop_down, color: buttonColor),
            underline: Container(),
          ),
        ],
      ),
    );
  }
} 