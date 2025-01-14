import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MeetingService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> sendMeetingInvite({
    required String roomCode,
    required List<String> participants,
    required String meetingTitle,
    DateTime? scheduledFor,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();

    // Create meeting document
    final meetingRef = _firestore.collection('meetings').doc();
    batch.set(meetingRef, {
      'roomCode': roomCode,
      'title': meetingTitle,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'scheduledFor': scheduledFor != null ? Timestamp.fromDate(scheduledFor) : null,
      'participants': participants,
      'status': 'pending',
    });

    // Create invitations for each participant
    for (final participant in participants) {
      final inviteRef = _firestore.collection('invitations').doc();
      batch.set(inviteRef, {
        'meetingId': meetingRef.id,
        'userId': participant,
        'status': 'pending',
        'sentAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
} 