import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:momenante_uploader/helpers/dialog_helper.dart';
import 'package:momenante_uploader/my_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        Navigator.of(context).pop(AutofillHints.familyName);
      }
      return false;
    }
  }
}
