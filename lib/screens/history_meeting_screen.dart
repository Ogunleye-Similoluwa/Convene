import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convene/screens/video_call_screen.dart';
import 'package:convene/utils/colors.dart';
import 'package:convene/widgets/animated_list_item.dart';
import 'package:convene/widgets/animated_meeting_card.dart';
import 'package:convene/widgets/page_transitions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryMeetingScreen extends StatelessWidget {
  const HistoryMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('meetings')
          .where('userId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text('No data available'),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final meetingData = documents[index].data() as Map<String, dynamic>;

            final roomName = meetingData['roomName'] ?? '';
            final userEmail = meetingData['userEmail'] ?? '';
            final userId = meetingData['userId'] ?? '';
            final userName = meetingData['userName'] ?? '';
            final meetingName = meetingData['meetingName'] ?? '';
            final createdAt = meetingData['createdAt'] != null
                ? (meetingData['createdAt'] as Timestamp).toDate()
                : null;
            final formattedDate =
                createdAt != null ? DateFormat.yMMMd().format(createdAt) : '';

            return AnimatedListItem(
              index: index,
              child: AnimatedMeetingCard(
                title: 'Room: $roomName',
                subtitle: 'Joined on $formattedDate',
                icon: Icons.meeting_room,
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      page: VideoCallScreen(roomCode: roomName),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class MeetingHistoryCard extends StatelessWidget {
  final String roomName;
  final String date;
  final String duration;
  final int participants;
  final VoidCallback onJoinAgain;

  const MeetingHistoryCard({
    required this.roomName,
    required this.date,
    required this.duration,
    required this.participants,
    required this.onJoinAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.meeting_room, color: buttonColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    roomName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onJoinAgain,
                  child: Text('Join Again'),
                  style: TextButton.styleFrom(
                    foregroundColor: buttonColor,
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.calendar_today, date),
                _buildInfoItem(Icons.timer, duration),
                _buildInfoItem(Icons.people, '$participants participants'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textColor.withOpacity(0.7)),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
