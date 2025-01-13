import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

// You'll need to get this from your Agora Console
const String appId = "2dd1e869fc9f4bb480c6bfcbc71f8aef";

class VideoCallScreen extends StatefulWidget {
  final String? roomCode;
  const VideoCallScreen({this.roomCode, super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final TextEditingController roomController = TextEditingController();
  bool isAudioMuted = true;
  bool isVideoMuted = true;
  bool isLoading = false;
  final User? user = FirebaseAuth.instance.currentUser;
  String? _lastUsedRoom;
  
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    if (widget.roomCode != null) {
      roomController.text = widget.roomCode!;
    }
    _loadLastUsedRoom();
    _checkPermissions();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    // Create RTC Engine instance
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user left");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
  }

  Future<void> _loadLastUsedRoom() async {
    try {
      final meetings = await FirebaseFirestore.instance
          .collection('meetings')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (meetings.docs.isNotEmpty) {
        setState(() {
          _lastUsedRoom = meetings.docs.first['roomName'];
        });
      }
    } catch (e) {
      debugPrint('Error loading last room: $e');
    }
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
          builder: (context, setState) {
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
                      'Please grant these permissions to use video calls:',
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(height: 16),
                    _buildPermissionListItem(
                      Icons.camera_alt,
                      'Camera',
                      permissions[Permission.camera] ?? false,
                      () async {
                        bool granted = await PermissionService.requestPermission(Permission.camera);
                        setState(() => permissions[Permission.camera] = granted);
                      },
                    ),
                    _buildPermissionListItem(
                      Icons.mic,
                      'Microphone',
                      permissions[Permission.microphone] ?? false,
                      () async {
                        bool granted = await PermissionService.requestPermission(Permission.microphone);
                        setState(() => permissions[Permission.microphone] = granted);
                      },
                    ),
                    _buildPermissionListItem(
                      Icons.bluetooth,
                      'Bluetooth',
                      permissions[Permission.bluetooth] ?? false,
                      () async {
                        bool granted = await PermissionService.requestPermission(Permission.bluetooth);
                        setState(() => permissions[Permission.bluetooth] = granted);
                      },
                    ),
                    _buildPermissionListItem(
                      Icons.calendar_today,
                      'Calendar',
                      permissions[Permission.calendar] ?? false,
                      () async {
                        bool granted = await PermissionService.requestPermission(Permission.calendar);
                        setState(() => permissions[Permission.calendar] = granted);
                      },
                    ),
                    // _buildPermissionListItem(
                    //   Icons.contacts,
                    //   'Contacts',
                    //   permissions[Permission.contacts] ?? false,
                    //   () async {
                    //     bool granted = await PermissionService.requestPermission(Permission.contacts);
                    //     setState(() => permissions[Permission.contacts] = granted);
                    //   },
                    // ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Done'),
                  onPressed: () {
                    if (!permissions.values.contains(false)) {
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please grant all permissions to continue'),
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
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
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
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
        ],
      ),
    );
  }

  Future<void> _joinMeeting() async {
    try {
      final roomCode = roomController.text.trim();
      
      if (roomCode.isEmpty) {
        showSnackBar(context, 'Please enter a room code', isError: true);
        return;
      }

      setState(() => isLoading = true);

      // Configure video encoding parameters
      await _engine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1920, height: 1080),
          frameRate: 30,
          bitrate: 3000,
        ),
      );

      // Set client role
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // Enable video
      await _engine.enableVideo();
      await _engine.enableAudio();

      // Set audio and video states based on user preferences
      await _engine.muteLocalAudioStream(isAudioMuted);
      await _engine.muteLocalVideoStream(isVideoMuted);

      // Join the channel
      await _engine.joinChannel(
        token: '',
        channelId: roomCode,
        uid: 0,
        options: const ChannelMediaOptions(),
      );

      // Store meeting details in Firestore
      await FirebaseFirestore.instance.collection('meetings').add({
        'roomName': roomCode,
        'userId': user?.uid,
        'userName': user?.displayName ?? 'User',
        'userEmail': user?.email ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (error) {
      debugPrint('Error joining meeting: $error');
      showSnackBar(context, 'Failed to join meeting: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        roomController.text = clipboardData!.text!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: textColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Join Meeting',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Animated Emoji
                    Center(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: secondaryBackgroundColor,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child:  Center(
                          child: AnimatedEmoji(
                              AnimatedEmojis.bubbles,
                            size: 64,
                            repeat: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Room Code Input
                    Container(
                      padding: const EdgeInsets.all(24),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Code',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: roomController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Enter room code',
                              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                              prefixIcon: Icon(Icons.meeting_room, color: buttonColor),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.content_paste, color: buttonColor),
                                onPressed: _pasteFromClipboard,
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          if (_lastUsedRoom != null) ...[
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                roomController.text = _lastUsedRoom!;
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.history, color: buttonColor, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Last used: $_lastUsedRoom',
                                    style: TextStyle(
                                      color: buttonColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meeting Settings
                    Container(
                      padding: const EdgeInsets.all(24),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meeting Settings',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSettingTile(
                            icon: Icons.mic,
                            title: 'Mute Audio',
                            subtitle: 'Join with audio muted',
                            value: isAudioMuted,
                            onChanged: (value) => setState(() => isAudioMuted = value),
                          ),
                          const SizedBox(height: 16),
                          _buildSettingTile(
                            icon: Icons.videocam,
                            title: 'Mute Video',
                            subtitle: 'Join with video muted',
                            value: isVideoMuted,
                            onChanged: (value) => setState(() => isVideoMuted = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Join Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _joinMeeting,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Join Meeting',
                                style: TextStyle(
                                  fontSize: 16,
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
          // Video views
          if (_remoteUid != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: roomController.text),
              ),
            ),
          if (_localUserJoined)
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 150,
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: buttonColor),
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
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    roomController.dispose();
    super.dispose();
  }
}
