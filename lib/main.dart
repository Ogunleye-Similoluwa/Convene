import 'package:convene/services/theme_customization_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:convene/resources/auth_methods.dart';
import 'package:convene/screens/history_meeting_screen.dart';
import 'package:convene/screens/home_screen.dart';
import 'package:convene/screens/MainScreen.dart';
import 'package:convene/screens/meeting_screen.dart';
import 'package:convene/screens/video_call_screen.dart';
import 'package:convene/utils/colors.dart';
import 'package:convene/screens/signin.dart';
import 'package:convene/screens/splash_screen.dart';
import 'package:convene/screens/login.dart';
import 'package:convene/screens/forgot_password_screen.dart';
import 'package:convene/services/theme_config_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  final themeConfig = await ThemeConfigService().getConfig();
  final themeCustomization = ThemeCustomizationService();
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Convene: Video Conferencce Apph@',
    theme: themeCustomization.getCustomTheme(
      ThemeData(
        useMaterial3: themeConfig.useMaterial3,
        textTheme: GoogleFonts.getTextTheme(themeConfig.fontFamily),
      ),
      await themeCustomization.getAccentColor(),
    ),
    routes: {
      '/splash-screen': (context) => ZoomSplashScreen(),
      '/login': (context) => LoginScreen(),
      '/signIn': (context) => SignInScreen(),
      '/home': (context) => HomeScreen(),
      '/main': (context) => MainScreen(),
      '/video-call': (context) => VideoCallScreen(),
      '/history-meeting-screen': (context) => HistoryMeetingScreen(),
      '/meeting-screen': (context) => MeetingScreen(), 
      '/forgot-password': (context) => const ForgotPasswordScreen(),
    },
    initialRoute: '/splash-screen',
    home: StreamBuilder(
        stream: AuthMethods().authChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const MainScreen();
        }),
  ));
}
// import 'package:flutter/material.dart';
// import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Meeting(),
//     );
//   }
// }

// class Meeting extends StatefulWidget {
//   const Meeting({Key? key}) : super(key: key);

//   @override
//   _MeetingState createState() => _MeetingState();
// }

// class _MeetingState extends State<Meeting> {
//   final serverText = TextEditingController();
//   final roomText = TextEditingController(text: "jitsi-meet-wrapper-test-room");
//   final subjectText = TextEditingController(text: "My Plugin Test Meeting");
//   final tokenText = TextEditingController();
//   final userDisplayNameText = TextEditingController(text: "Plugin Test User");
//   final userEmailText = TextEditingController(text: "fake@email.com");
//   final userAvatarUrlText = TextEditingController();

//   bool isAudioMuted = true;
//   bool isAudioOnly = false;
//   bool isVideoMuted = true;

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Jitsi Meet Wrapper Test')),
//         body: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: buildMeetConfig(),
//         ),
//       ),
//     );
//   }

//   Widget buildMeetConfig() {
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           const SizedBox(height: 16.0),
//           _buildTextField(
//             labelText: "Server URL",
//             controller: serverText,
//             hintText: "Hint: Leave empty for meet.jitsi.si",
//           ),
//           const SizedBox(height: 16.0),
//           _buildTextField(labelText: "Room", controller: roomText),
//           const SizedBox(height: 16.0),
//           _buildTextField(labelText: "Subject", controller: subjectText),
//           const SizedBox(height: 16.0),
//           _buildTextField(labelText: "Token", controller: tokenText),
//           const SizedBox(height: 16.0),
//           _buildTextField(
//             labelText: "User Display Name",
//             controller: userDisplayNameText,
//           ),
//           const SizedBox(height: 16.0),
//           _buildTextField(
//             labelText: "User Email",
//             controller: userEmailText,
//           ),
//           const SizedBox(height: 16.0),
//           _buildTextField(
//             labelText: "User Avatar URL",
//             controller: userAvatarUrlText,
//           ),
//           const SizedBox(height: 16.0),
//           CheckboxListTile(
//             title: const Text("Audio Muted"),
//             value: isAudioMuted,
//             onChanged: _onAudioMutedChanged,
//           ),
//           const SizedBox(height: 16.0),
//           CheckboxListTile(
//             title: const Text("Audio Only"),
//             value: isAudioOnly,
//             onChanged: _onAudioOnlyChanged,
//           ),
//           const SizedBox(height: 16.0),
//           CheckboxListTile(
//             title: const Text("Video Muted"),
//             value: isVideoMuted,
//             onChanged: _onVideoMutedChanged,
//           ),
//           const Divider(height: 48.0, thickness: 2.0),
//           SizedBox(
//             height: 64.0,
//             width: double.maxFinite,
//             child: ElevatedButton(
//               onPressed: () => _joinMeeting(),
//               child: const Text(
//                 "Join Meeting",
//                 style: TextStyle(color: Colors.white),
//               ),
//               style: ButtonStyle(
//                 backgroundColor:
//                     MaterialStateColor.resolveWith((states) => Colors.blue),
//               ),
//             ),
//           ),
//           const SizedBox(height: 48.0),
//         ],
//       ),
//     );
//   }

//   _onAudioOnlyChanged(bool? value) {
//     setState(() {
//       isAudioOnly = value!;
//     });
//   }

//   _onAudioMutedChanged(bool? value) {
//     setState(() {
//       isAudioMuted = value!;
//     });
//   }

//   _onVideoMutedChanged(bool? value) {
//     setState(() {
//       isVideoMuted = value!;
//     });
//   }

//   _joinMeeting() async {
//     String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

//     Map<String, Object> featureFlags = {};

//     // Define meetings options here
//     var options = JitsiMeetingOptions(
//       roomNameOrUrl: roomText.text,
//       serverUrl: serverUrl,
//       subject: subjectText.text,
//       token: tokenText.text,
//       isAudioMuted: isAudioMuted,
//       isAudioOnly: isAudioOnly,
//       isVideoMuted: isVideoMuted,
//       userDisplayName: userDisplayNameText.text,
//       userEmail: userEmailText.text,
//       featureFlags: featureFlags,
//     );

//     debugPrint("JitsiMeetingOptions: $options");
//     await JitsiMeetWrapper.joinMeeting(
//       options: options,
//       listener: JitsiMeetingListener(
//         onOpened: () => debugPrint("onOpened"),
//         onConferenceWillJoin: (url) {
//           debugPrint("onConferenceWillJoin: url: $url");
//         },
//         onConferenceJoined: (url) {
//           debugPrint("onConferenceJoined: url: $url");
//         },
//         onConferenceTerminated: (url, error) {
//           debugPrint("onConferenceTerminated: url: $url, error: $error");
//         },
//         onAudioMutedChanged: (isMuted) {
//           debugPrint("onAudioMutedChanged: isMuted: $isMuted");
//         },
//         onVideoMutedChanged: (isMuted) {
//           debugPrint("onVideoMutedChanged: isMuted: $isMuted");
//         },
//         onScreenShareToggled: (participantId, isSharing) {
//           debugPrint(
//             "onScreenShareToggled: participantId: $participantId, "
//             "isSharing: $isSharing",
//           );
//         },
//         onParticipantJoined: (email, name, role, participantId) {
//           debugPrint(
//             "onParticipantJoined: email: $email, name: $name, role: $role, "
//             "participantId: $participantId",
//           );
//         },
//         onParticipantLeft: (participantId) {
//           debugPrint("onParticipantLeft: participantId: $participantId");
//         },
//         onParticipantsInfoRetrieved: (participantsInfo, requestId) {
//           debugPrint(
//             "onParticipantsInfoRetrieved: participantsInfo: $participantsInfo, "
//             "requestId: $requestId",
//           );
//         },
//         onChatMessageReceived: (senderId, message, isPrivate) {
//           debugPrint(
//             "onChatMessageReceived: senderId: $senderId, message: $message, "
//             "isPrivate: $isPrivate",
//           );
//         },
//         onChatToggled: (isOpen) => debugPrint("onChatToggled: isOpen: $isOpen"),
//         onClosed: () => debugPrint("onClosed"),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String labelText,
//     required TextEditingController controller,
//     String? hintText,
//   }) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//           border: const OutlineInputBorder(),
//           labelText: labelText,
//           hintText: hintText),
//     );
//   }
// }