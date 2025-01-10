import 'dart:math';
import 'package:convene/services/permission_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
// import '../widgets/home_meeting_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  bool _isCreatingMeeting = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool hasPermissions = await PermissionService.checkPermissions();
    if (!hasPermissions) {
      _showPermissionDialog();
    }
  }

  Future<void> _showPermissionDialog() async {
    Map<Permission, bool> permissions = await PermissionService.checkIndividualPermissions();
    
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Permissions Required',
                style: TextStyle(color: textColor),
              ),
              backgroundColor: secondaryBackgroundColor,
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Camera and microphone access is required for video calls. Please enable them in Settings.',
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(height: 16),
                    _buildPermissionListItem(
                      Icons.camera_alt,
                      'Camera',
                      permissions[Permission.camera] ?? false,
                      () async {
                        if (await Permission.camera.isPermanentlyDenied) {
                          // Show settings dialog
                          _showSettingsDialog();
                        } else {
                          bool granted = await PermissionService.requestPermission(Permission.camera);
                          setDialogState(() {
                            permissions[Permission.camera] = granted;
                          });
                          setState(() {});
                        }
                      },
                    ),
                    _buildPermissionListItem(
                      Icons.mic,
                      'Microphone',
                      permissions[Permission.microphone] ?? false,
                      () async {
                        if (await Permission.microphone.isPermanentlyDenied) {
                          // Show settings dialog
                          _showSettingsDialog();
                        } else {
                          bool granted = await PermissionService.requestPermission(Permission.microphone);
                          setDialogState(() {
                            permissions[Permission.microphone] = granted;
                          });
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Open Settings',
                    style: TextStyle(color: buttonColor),
                  ),
                  onPressed: () async {
                    await openAppSettings();
                  },
                ),
                TextButton(
                  child: Text(
                    'Done',
                    style: TextStyle(color: buttonColor),
                  ),
                  onPressed: () {
                    if (!permissions.values.contains(false)) {
                      Navigator.of(context).pop(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enable permissions in Settings to continue'),
                          backgroundColor: errorColor,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSettingsDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enable Permissions',
            style: TextStyle(color: textColor),
          ),
          backgroundColor: secondaryBackgroundColor,
          content: Text(
            'Please enable camera and microphone access in your device settings to use video calls.',
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Open Settings',
                style: TextStyle(color: buttonColor),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionListItem(
    IconData icon,
    String text,
    bool isGranted,
    VoidCallback onRequest,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: buttonColor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          if (!isGranted)
            TextButton(
              onPressed: onRequest,
              child: Text(
                'Allow',
                style: TextStyle(
                  color: buttonColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  createNewMeeting() async {
    try {
      print('Starting new meeting creation...');
      
      // Check permissions first
      bool hasPermissions = await PermissionService.checkPermissions();
      print('Permissions check result: $hasPermissions');
      
      if (!hasPermissions) {
        print('Permissions not granted, showing dialog...');
        await _showPermissionDialog();
        hasPermissions = await PermissionService.checkPermissions();
        print('Permissions after dialog: $hasPermissions');
        
        if (!hasPermissions) {
          print('Still missing permissions');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot create meeting without camera and microphone access'),
              backgroundColor: errorColor,
            ),
          );
          return;
        }
      }

      setState(() => _isCreatingMeeting = true);
      
      var random = Random();
      String roomName = (random.nextInt(10000000) + 10000000).toString();
      print('Generated room name: $roomName');

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Creating meeting with room: $roomName');
        
        var options = JitsiMeetingOptions(
          roomNameOrUrl: roomName,
          serverUrl: "https://meet.jit.si",  // Make sure using jit.si
          isAudioMuted: false,
          isVideoMuted: false,
          userDisplayName: user.displayName ?? "Host User",
          userEmail: user.email,
          featureFlags: {
            "chat.enabled": true,
            "meeting-name.enabled": true,
            "raise-hand.enabled": true,
            "recording.enabled": false,
            "live-streaming.enabled": false,
            "tile-view.enabled": true,
            "toolbox.enabled": true,
            "welcome-page.enabled": false,
            "prejoinpage.enabled": false,  // Skip prejoin page
          },
        );

        print('Attempting to join meeting with options...');
        await JitsiMeetWrapper.joinMeeting(
          options: options,
          listener: JitsiMeetingListener(
            onConferenceWillJoin: (url) {
              print('Conference will join: $url');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Joining meeting...'))
              );
            },
            onConferenceJoined: (url) {
              print('Conference joined successfully: $url');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Joined meeting!'))
              );
            },
            onConferenceTerminated: (url, error) {
              print('Conference terminated. URL: $url, Error: $error');
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Meeting ended: $error'),
                    backgroundColor: errorColor,
                  )
                );
              }
            },
          ),
        );

        print('Storing meeting details in Firestore...');
        await FirebaseFirestore.instance.collection('meetings').add({
          'roomName': roomName,
          'userId': user.uid,
          'userName': user.displayName ?? '',
          'userEmail': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Meeting details stored successfully');
      }
    } catch (error) {
      print('Error creating meeting: $error');
      print('Stack trace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create meeting: $error'),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      setState(() => _isCreatingMeeting = false);
    }
  }

  joinMeeting(BuildContext context) {
    Navigator.pushNamed(context, '/video-call');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Meetings',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create or join meetings with a single tap',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // Quick Actions Card
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
                    children: [
                      // New Meeting Button
                      _buildActionButton(
                        onPressed: _isCreatingMeeting ? null : () => createNewMeeting(),
                        text: 'New Meeting',
                        icon: Icons.videocam,
                        description: 'Create a new meeting instantly',
                        isLoading: _isCreatingMeeting,
                        showBorder: true,
                      ),
                      // Join Meeting Button
                      _buildActionButton(
                        onPressed: () => joinMeeting(context),
                        text: 'Join Meeting',
                        icon: Icons.add_box_rounded,
                        description: 'Join with a meeting code',
                        showBorder: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Features Section
                Text(
                  'Premium Features',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Feature Cards
                _buildFeatureCard(
                  icon: Icons.security,
                  title: 'Secure Meetings',
                  description: 'End-to-end encryption for all meetings',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.people,
                  title: 'Multiple Participants',
                  description: 'Host meetings with up to 100 participants',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.screen_share,
                  title: 'Screen Sharing',
                  description: 'Share your screen with participants',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    required String description,
    bool isLoading = false,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: showBorder ? Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: buttonColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                      ),
                    )
                  : Icon(icon, color: buttonColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: buttonColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
