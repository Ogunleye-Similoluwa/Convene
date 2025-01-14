import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  @override
  _ScheduleMeetingScreenState createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<String> participants = [];
  bool isRecurring = false;
  String recurringType = 'weekly';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: buttonColor,
              onPrimary: Colors.white,
              surface: secondaryBackgroundColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: buttonColor,
              onPrimary: Colors.white,
              surface: secondaryBackgroundColor,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _scheduleMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final meetingDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final meetingData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'scheduledFor': Timestamp.fromDate(meetingDateTime),
        'createdBy': user.uid,
        'participants': participants,
        'isRecurring': isRecurring,
        'recurringType': isRecurring ? recurringType : null,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('scheduledMeetings')
          .add(meetingData);

      // Send notifications to participants
      for (String participant in participants) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': participant,
          'type': 'meeting_invitation',
          'title': 'New Meeting Invitation',
          'message': 'You have been invited to ${titleController.text}',
          'meetingTime': Timestamp.fromDate(meetingDateTime),
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meeting scheduled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scheduling meeting: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Schedule Meeting',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meeting Details Section
                _buildSectionHeader('Meeting Details'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: titleController,
                  label: 'Meeting Title',
                  icon: Icons.title,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Date & Time Section
                _buildSectionHeader('Date & Time'),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: secondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildDateTimeTile(
                        icon: Icons.calendar_today,
                        title: 'Date',
                        value: DateFormat('MMM dd, yyyy').format(selectedDate),
                        onTap: () => _selectDate(context),
                      ),
                      Divider(height: 1, color: backgroundColor),
                      _buildDateTimeTile(
                        icon: Icons.access_time,
                        title: 'Time',
                        value: selectedTime.format(context),
                        onTap: () => _selectTime(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recurring Options
                _buildSectionHeader('Recurring Meeting'),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: secondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.repeat, color: buttonColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Repeat Meeting',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: isRecurring,
                            onChanged: (value) => setState(() => isRecurring = value),
                            activeColor: buttonColor,
                          ),
                        ],
                      ),
                      if (isRecurring) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: recurringType,
                              isExpanded: true,
                              dropdownColor: secondaryBackgroundColor,
                              items: ['daily', 'weekly', 'monthly'].map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type.toUpperCase(),
                                    style: TextStyle(color: textColor),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) setState(() => recurringType = value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Participants Section
                _buildSectionHeader('Participants'),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: secondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, color: buttonColor),
                          const SizedBox(width: 12),
                          Text(
                            'Add Participants',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.person_add, color: buttonColor),
                            onPressed: _showAddParticipantDialog,
                          ),
                        ],
                      ),
                      if (participants.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: participants.map((email) {
                            return Chip(
                              label: Text(
                                email,
                                style: TextStyle(color: textColor),
                              ),
                              backgroundColor: buttonColor.withOpacity(0.1),
                              deleteIcon: Icon(Icons.close, size: 18),
                              onDeleted: () {
                                setState(() => participants.remove(email));
                              },
                              deleteIconColor: buttonColor,
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Schedule Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _scheduleMeeting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Schedule Meeting',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor),
          prefixIcon: Icon(icon, color: buttonColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: secondaryBackgroundColor,
          contentPadding: EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateTimeTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: buttonColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Future<void> _showAddParticipantDialog() async {
    final emailController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryBackgroundColor,
        title: Text('Add Participant', style: TextStyle(color: textColor)),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty && email.contains('@')) {
                setState(() => participants.add(email));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
            ),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
} 