import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 💡 Import SharedPreferences
import '../config/api_config.dart';

class ConsultationService {
  // 💡 FUNGSI HELPER: Persis seperti yang Anda gunakan di service lain
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
        'access_token'); // Sesuaikan key 'token' jika di project Anda namanya berbeda
  }

  // 1. Mengambil riwayat chat
  static Future<List<dynamic>> getMessages() async {
    try {
      final token =
          await _getToken(); // 💡 Memanggil fungsi dengan cara yang sama

      if (token == null) return [];

      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/consultation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error getMessages: $e");
      return [];
    }
  }

  // 2. Mengirim pesan baru
  static Future<bool> sendMessage(String message) async {
    try {
      final token =
          await _getToken(); // 💡 Memanggil fungsi dengan cara yang sama

      if (token == null) return false;

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/consultation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("====================================");
      print("🔴 ERROR KIRIM PESAN: $e");
      print("====================================");
      return false;
    }
  }
}
