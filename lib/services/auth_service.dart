import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<void> login(String email, String password) async {
    await _api.login(email, password);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _api.register(
      name: name,
      email: email,
      password: password,
    );
  }

  void logout() {}
}
