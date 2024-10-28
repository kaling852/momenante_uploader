import 'package:permission_handler/permission_handler.dart';

class MediaPermissionHelper {

  // Function to check storage permission
  static Future<bool> askStoragePermission() async {
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isDenied || status.isRestricted) {
      // Request permission
      status = await Permission.photos.request();
    }

    // Check if permission is permanently denied
    if (status.isPermanentlyDenied) {
      // Open the app settings if permission is permanently denied
      openAppSettings();
    }

    return status.isGranted || status.isLimited;
  }

  static Future<bool> checkMediaPermission() async {
    final PermissionStatus status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }
    return false;
  }

}