import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class PermissionService {
  static Future<Map<Permission, bool>> checkIndividualPermissions() async {
    // Force refresh the permission status
    await Permission.camera.status;
    await Permission.microphone.status;
    
    return {
      Permission.camera: await Permission.camera.isGranted,
      Permission.microphone: await Permission.microphone.isGranted,
    };
  }

  static Future<bool> requestPermission(Permission permission) async {
    try {
      print('Requesting permission: ${permission.toString()}');
      
      // Request the permission regardless of current status on iOS
      if (Platform.isIOS) {
        final status = await permission.request();
        print('iOS Permission status after request: $status');
        // Wait a bit for the status to update
        await Future.delayed(Duration(milliseconds: 100));
        final finalStatus = await permission.status;
        print('iOS Final permission status: $finalStatus');
        return finalStatus.isGranted;
      }
      
      // For Android, follow the normal flow
      final status = await permission.request();
      print('Android Permission status: $status');
      return status.isGranted;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  static Future<void> logPermissionStatuses() async {
    print('Platform: ${Platform.isIOS ? "iOS" : "Android"}');
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    print('Camera permission status: $camera');
    print('Microphone permission status: $mic');
    print('Camera is granted: ${camera.isGranted}');
    print('Microphone is granted: ${mic.isGranted}');
  }

  static Future<bool> checkPermissions() async {
    await logPermissionStatuses();
    
    if (Platform.isIOS) {
      // For iOS, check the actual status
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;
      return cameraStatus.isGranted && micStatus.isGranted;
    }
    
    Map<Permission, bool> permissions = await checkIndividualPermissions();
    return !permissions.values.contains(false);
  }

  static Future<bool> resetPermissions() async {
    if (Platform.isIOS) {
      // On iOS, direct the user to Settings
      return await openAppSettings();
    } else {
      // On Android, try to request again
      bool cameraGranted = await requestPermission(Permission.camera);
      bool micGranted = await requestPermission(Permission.microphone);
      return cameraGranted && micGranted;
    }
  }
} 