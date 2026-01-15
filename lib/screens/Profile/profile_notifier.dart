import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileNotifier extends ChangeNotifier {
  String name = '';
  String email = '';
  String? imageUrl;

  ProfileNotifier() {
    loadProfile();
  }

  // ================= LOAD SAVED PROFILE =================
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('profile_name') ?? '';
    email = prefs.getString('profile_email') ?? '';
    imageUrl = prefs.getString('profile_image');
    notifyListeners();
  }

  // ================= SET NAME + EMAIL + IMAGE =================
  Future<void> setUser({
    required String newName,
    required String newEmail,
    String? newImageUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    name = newName;
    email = newEmail;
    imageUrl = newImageUrl ?? imageUrl;

    await prefs.setString('profile_name', name);
    await prefs.setString('profile_email', email);

    if (imageUrl != null) {
      await prefs.setString('profile_image', imageUrl!);
    }

    notifyListeners();
  }

  // ================= SET IMAGE ONLY =================
  Future<void> setImage(String url) async {
    final prefs = await SharedPreferences.getInstance();
    imageUrl = url;
    await prefs.setString('profile_image', url);
    notifyListeners();
  }

  // ================= CLEAR (LOGOUT) =================
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    name = '';
    email = '';
    imageUrl = null;

    notifyListeners();
  }
}
