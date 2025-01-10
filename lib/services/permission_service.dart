import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<Map<Permission, bool>> checkIndividualPermissions() async {
    return {
      Permission.camera: await Permission.camera.isGranted,
      Permission.microphone: await Permission.microphone.isGranted,
    };
  }

  static Future<bool> requestPermission(Permission permission) async {
    try {
      print('Requesting permission: ${permission.toString()}');
      
      if (await permission.isPermanentlyDenied) {
        print('Permission is permanently denied');
        return false;
      }
      
      PermissionStatus status = await permission.request();
      print('Permission status: ${status.toString()}');
      return status.isGranted;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  static Future<void> logPermissionStatuses() async {
    print('Camera permission status: ${await Permission.camera.status}');
    print('Microphone permission status: ${await Permission.microphone.status}');
    
    print('Camera is granted: ${await Permission.camera.isGranted}');
    print('Microphone is granted: ${await Permission.microphone.isGranted}');
  }

  static Future<bool> checkPermissions() async {
    await logPermissionStatuses();
    Map<Permission, bool> permissions = await checkIndividualPermissions();
    return !permissions.values.contains(false);
  }

  static Future<bool> openSettings() async {
    return await openAppSettings();
  }
} 