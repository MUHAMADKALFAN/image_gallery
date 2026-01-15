import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.68.123:8000",
    ),
  );

  // =====================
  // LOGIN
  // =====================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post(
      "/login",
      data: {
        "email": email,
        "password": password,
      },
    );
    return response.data;
  }

  // =====================
  // REGISTER
  // =====================
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await dio.post(
      "/register",
      data: {
        "name": name,
        "email": email,
        "password": password,
      },
    );
  }

  // =====================
  // UPLOAD PROFILE IMAGE ✅ FIXED
  // =====================
  Future<String> uploadProfileImage({
    required String email,
    required File image,
  }) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    final response = await dio.post(
      "/upload-profile-image/$email", // ✅ email PATH param
      data: formData,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    return response.data["image_url"];
  }
}
