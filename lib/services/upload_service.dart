import 'dart:io';
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
        // show loading dialog during upload
        DialogHelper.showLoadingDialog(context, "Uploading... Please wait.");

        // Resize the image if needed
        imageFile = await _resizeImageIfNeeded(imageFile);

        await Supabase.instance.client.storage.from(bucketName).upload(
            filePath,
            imageFile,
            // allow override the same file
            fileOptions: const FileOptions(upsert: true)
        );
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      }
      return true;
    } catch (e) {
      MyLog("UploadService:uploadImage").log(e.toString());
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return false;
    }
  }

  Future<File> _resizeImageIfNeeded(File imageFile) async {
    const maxHeight = 1000;
    const maxWidth = 1000;
    final originalImage = img.decodeImage(await imageFile.readAsBytes());

    if (originalImage == null) return imageFile;

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

    final resizedImage = img.copyResize(
      originalImage,
      width: newWidth,
      height: newHeight,
    );
    
    final resizedImageFile = File(imageFile.path);
    resizedImageFile.writeAsBytesSync(img.encodeJpg(resizedImage));

    return resizedImageFile;
  }

}
