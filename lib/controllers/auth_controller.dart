import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthController {
  Future<bool> register(String name, String email, String password) async {
    try {
      await AuthService.register(name, email, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await AuthService.login(email, password);

      // Ambil token dari Laravel
      final token = response['data']['access_token'];

      // Simpan ke local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }
}
