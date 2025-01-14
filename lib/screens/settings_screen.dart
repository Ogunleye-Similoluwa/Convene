import 'package:convene/screens/home_screen.dart';
import 'package:convene/widgets/animated_list_item.dart';
import 'package:convene/widgets/animated_ripple_card.dart';
import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/animation_service.dart';
import '../utils/colors.dart';
import '../widgets/theme_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = SharedPreferences.getInstance();
  bool meetingReminders = true;
  bool emailNotifications = true;
  int reminderTime = 15;
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool isDarkMode = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false ,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 24,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile Section
            _buildProfileSection(),
            
            // Settings Sections
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSettingsSection(
                    title: 'Notifications',
                    icon: Icons.notifications_outlined,
                    children: [
                      _buildSwitchTile(
                        title: 'Meeting Reminders',
                        subtitle: 'Get notified before meetings start',
                        icon: Icons.calendar_today,
                        value: meetingReminders,
                        onChanged: (value) {
                          setState(() => meetingReminders = value);
                          _saveNotificationPreferences();
                        },
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        title: 'Email Notifications',
                        subtitle: 'Receive meeting invites and updates',
                        icon: Icons.mail_outline,
                        value: emailNotifications,
                        onChanged: (value) {
                          setState(() => emailNotifications = value);
                          _saveNotificationPreferences();
                        },
                      ),
                      _buildDivider(),
                      _buildReminderTimeTile(),
                    ],
                  ),
                  // SizedBox(height: 20),
                  // _buildSettingsSection(
                  //   title: 'Appearance',
                  //   icon: Icons.palette_outlined,
                  //   children: [
                  //     _buildSwitchTile(
                  //       title: 'Dark Mode',
                  //       subtitle: 'Toggle dark/light theme',
                  //       icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  //       value: isDarkMode,
                  //       onChanged: (value) {
                  //         setState(() => isDarkMode = value);
                  //         // Add theme change logic
                  //       },
                  //     ),
                  //     _buildDivider(),
                  //     _buildColorPicker(),
                  //   ],
                  // ),
                  SizedBox(height: 20),
                  _buildSettingsSection(
                    title: 'Sound & Haptics',
                    icon: Icons.volume_up_outlined,
                    children: [
                      _buildSwitchTile(
                        title: 'Sound Effects',
                        subtitle: 'Play sounds for notifications',
                        icon: Icons.music_note,
                        value: soundEnabled,
                        onChanged: (value) {
                          setState(() => soundEnabled = value);
                          _saveNotificationPreferences();
                        },
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        title: 'Vibration',
                        subtitle: 'Haptic feedback for actions',
                        icon: Icons.vibration,
                        value: vibrationEnabled,
                        onChanged: (value) {
                          setState(() => vibrationEnabled = value);
                          _saveNotificationPreferences();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildSettingsSection(
                    title: 'Logout`',
                    icon: Icons.logout,
                    children: [
                      CustomButton(
                        text: 'Log Out',
                        onPressed: () => CustomButton.logout(context),
                      ),
                    ]
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            buttonColor.withOpacity(0.8),
            buttonColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: user?.photoURL != null 
                ? NetworkImage(user!.photoURL!) 
                : null,
            child: user?.photoURL == null 
                ? Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Add edit profile logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: buttonColor),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: buttonColor),
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
                      subtitle,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: buttonColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderTimeTile() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.timer, color: buttonColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder Time',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Minutes before meeting',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<int>(
              value: reminderTime,
              items: [5, 10, 15, 30, 60].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    '$value min',
                    style: TextStyle(
                      color: buttonColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => reminderTime = value);
                  _saveNotificationPreferences();
                }
              },
              dropdownColor: secondaryBackgroundColor,
              icon: Icon(Icons.arrow_drop_down, color: buttonColor),
              underline: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.color_lens, color: buttonColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accent Color',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Choose your preferred color',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Add color picker widget here
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: textColor.withOpacity(0.1),
      height: 1,
      indent: 64,
    );
  }

  Future<void> _saveNotificationPreferences() async {
    final prefs = await _prefs;
    await prefs.setBool('meeting_reminders', meetingReminders);
    await prefs.setBool('email_notifications', emailNotifications);
    await prefs.setInt('reminder_time', reminderTime);
    await prefs.setBool('sound_enabled', soundEnabled);
    await prefs.setBool('vibration_enabled', vibrationEnabled);
  }
} 