import 'package:flutter/material.dart';
import 'package:momenante_uploader/helpers/dialog_helper.dart';
import 'package:momenante_uploader/my_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  // check authentication status and log the result
  Future<void> checkAuthStatus(BuildContext context) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (context.mounted) {
        _showLoginDialog(context);
      }
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      MyLog("AuthService:logout").log("Error logout: $e");
    }
  }

  // showLoginDialog
  void _showLoginDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {

                bool success = await _loginUser(emailController.text, passwordController.text);
                if (success) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } else {
                  if (context.mounted) {
                    DialogHelper.showErrorDialog(context, "Login failed, please try again.");
                  }
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  // Function to handle login logic
  Future<bool> _loginUser(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        return false;
      }
      return true;
    } catch (e) {
      MyLog("AuthService:_loginUser").log("Error logging in: $e");
      return false;
    }
  }

}