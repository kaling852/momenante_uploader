import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:momenante_uploader/helpers/dialog_helper.dart';
import 'package:momenante_uploader/my_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;

class UploadService {

  // Upload image to Supabase Storage
  Future<bool> uploadImage(BuildContext context, File imageFile) async {
    await dotenv.load(fileName: ".env");
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? "";
    final bucketName = dotenv.env['SUPABASE_PHOTOS_BUCKET'] ?? '';
    if (userId.isEmpty || bucketName.isEmpty) {
      return false;
    }

    final DateTime now = DateTime.now();
    String year = DateFormat('yyyy').format(now);
    String month = DateFormat('MM').format(now);
    String day = DateFormat('dd').format(now);

    // example : 1027.jpg
    String fileName = "$month$day.${imageFile.path.split('.').last}";
    String filePath = '$userId/$year/$month/$fileName';

    try {

      if (context.mounted) {
        DialogHelper.showLoadingDialog(context, "Resizing image... Please wait.", false);
        imageFile = await _resizeImageIfNeeded(imageFile);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }

      if (context.mounted) {
        DialogHelper.showLoadingDialog(context, "Uploading... Please wait.");
        await Supabase.instance.client.storage.from(bucketName).upload(
          filePath,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );
      }

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }

      return true;
    } catch (e) {
      MyLog("UploadService:uploadImage").log(e.toString());
      // Ensure the dialog is dismissed on error
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return false;
    }
  }

  Future<File> _resizeImageIfNeeded(File imageFile) async {
    final receivePort = ReceivePort();

    // Read image bytes asynchronously **before spawning the isolate**
    final Uint8List imageBytes = await imageFile.readAsBytes();

    // Spawn an isolate and send the raw bytes (not the file path)
    await Isolate.spawn(_resizeImageInIsolate, [receivePort.sendPort, imageBytes]);

    // Receive the resized image bytes asynchronously
    final Uint8List resizedImageBytes = await receivePort.first as Uint8List;

    // Write resized bytes back to the file **asynchronously**
    return imageFile.writeAsBytes(resizedImageBytes);
  }

  void _resizeImageInIsolate(List<dynamic> args) {
    SendPort sendPort = args[0];
    Uint8List imageBytes = args[1]; // Expecting raw bytes, not a file path

    const int maxHeight = 1000;
    const int maxWidth = 1000;

    try {
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        sendPort.send(imageBytes); // If decoding fails, return original bytes
        return;
      }

      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (originalImage.height > maxHeight) {
        newHeight = maxHeight;
        newWidth = (originalImage.width * maxHeight / originalImage.height).round();
      }

      if (originalImage.width > maxWidth) {
        newWidth = maxWidth;
        newHeight = (originalImage.height * maxWidth / originalImage.width).round();
      }

      final resizedImage = img.copyResize(originalImage, width: newWidth, height: newHeight);
      final Uint8List resizedImageBytes = Uint8List.fromList(img.encodeJpg(resizedImage));

      sendPort.send(resizedImageBytes); // Send back processed image bytes
    } catch (e) {
      print("Error resizing image in isolate: $e");
      sendPort.send(imageBytes); // Send original bytes if error occurs
    }
  }
}
