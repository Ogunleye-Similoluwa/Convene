import 'package:convene/widgets/animated_list_item.dart';
import 'package:convene/widgets/animated_ripple_card.dart';
import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/animation_service.dart';
import '../utils/colors.dart';
import '../widgets/theme_preview.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSettingsGroup(
            title: 'Account',
            items: [
              _buildSettingsItem(
                icon: Icons.person,
                title: 'Profile',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.notifications,
                title: 'Notifications',
                onTap: () {},
              ),
            ],
          ),
          _buildSettingsGroup(
            title: 'Appearance',
            items: [
              _buildSettingsItem(
                icon: Icons.palette,
                title: 'Theme',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.font_download,
                title: 'Font',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required List<Widget> items,
  }) {
    return AnimatedListItem(
      index: title == 'Account' ? 0 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return AnimatedRippleCard(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: secondaryBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: buttonColor),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
} 