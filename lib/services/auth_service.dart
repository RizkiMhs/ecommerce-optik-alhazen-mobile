import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.registerEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Register gagal');
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.loginEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // 🔥 INI WAJIB
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    // ✅ TAMBAHKAN DI SINI
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    print(response.headers);
    print(ApiConfig.loginEndpoint);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }
}
