// controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../role_selections/views/role_selection_view.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Attempts to sign in with Email and Password.
  Future<void> signInWithEmail() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Success! The SplashController's stream will
      // see the 'signedIn' event and handle redirection.
    } on AuthException catch (e) {
      // Show "No user" or "Wrong password" error
      _showError('Login Failed', e.message);
    } catch (e) {
      _showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Attempts to sign in with Google.
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      // Success! SplashController will handle the redirect.
    } on AuthException catch (e) {
      _showError('Google Sign-In Failed', e.message);
      isLoading.value = false;
    } catch (e) {
      _showError('Error', e.toString());
      isLoading.value = false;
    }
    // Don't set isLoading=false on success, as the app
    // will be busy handling the redirect.
  }

  /// Attempts to sign in with Facebook.
  Future<void> signInWithFacebook() async {
    isLoading.value = true;
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      // Success! SplashController will handle the redirect.
    } on AuthException catch (e) {
      _showError('Facebook Sign-In Failed', e.message);
      isLoading.value = false;
    } catch (e) {
      _showError('Error', e.toString());
      isLoading.value = false;
    }
  }

  /// Stub for Phone Sign-In.
  void signInWithPhone() {
    Get.snackbar(
        'Coming Soon', 'Phone number login will be available soon.');
  }

  /// Navigates to the "Sign Up" flow (Role Selection).
  void navigateToSignUp() {
    Get.to(() => RoleSelectionView());
  }

  /// Helper to show a snackbar error.
  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}