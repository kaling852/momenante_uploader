import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:momenante_uploader/helpers/media_permission_helper.dart';
import 'package:momenante_uploader/themes/theme.dart';
import 'package:momenante_uploader/services/upload_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'helpers/dialog_helper.dart';

void main() async {
  // ensure that the Flutter framework is fully initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  // Use the helper function to check permission
  Future<void> _checkPermission() async {
    bool permissionGranted = await MediaPermissionHelper.checkMediaPermission();
    setState(() {
      // Update the state based on permission
      _hasPermission = permissionGranted;
    });
  }

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      if (context.mounted) {
        File imageFile = File(pickedFile.path);
        bool? confirmed = await DialogHelper.showImageConfirmationDialog(context, imageFile);

        if (confirmed == true && context.mounted) {
          UploadService uploadService = UploadService();
          bool success = await uploadService.uploadImage(context, imageFile);
          if (context.mounted) {
            if (success) {
              DialogHelper.showCheckMarkDialog(context, "Upload successful!");
            } else {
              DialogHelper.showErrorDialog(context);
            }
          }
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    }
  }

  bool _isAuthCheckDone = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momenante Upload App',
      theme: darkTheme,
      home: Builder(
        builder: (context) {
          // Check authentication status and show dialog if needed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isAuthCheckDone) {
              _authService.checkAuthStatus(context);
              _isAuthCheckDone = true;
            }
          });
          return Scaffold(
              appBar: AppBar(
                title: const Text("Momenante Upload App"),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hasPermission) ...[
                      const Text(
                        "Ready to Upload Your Image?", // Custom text
                        style: TextStyle(fontSize: 18), // Style customization
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _pickImage(context, ImageSource.gallery);
                        },
                        child: const Text("Select an Image"),
                      ),
                    ] else... [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                        "We need access to your media storage to upload images. "
                        "\n\nPlease grant permission so that you can select and upload "
                        "your images securely.",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          bool permissionGranted = await MediaPermissionHelper.askStoragePermission();
                          if (permissionGranted) {
                            setState(() {
                              _hasPermission = true;
                            });
                          }
                        },
                        child: const Text("Give Permission"),
                      ),
                    ]
                  ],
                ),
              ),
          );
        },
      ),
    );
  }
}
