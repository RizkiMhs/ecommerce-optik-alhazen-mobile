import 'dart:convert';
import 'dart:io'; // 💡 Penting untuk membaca File gambar
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ConsultationService {
  // FUNGSI HELPER: Ambil Token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token'); 
  }

  // 1. Mengambil riwayat chat
  static Future<List<dynamic>> getMessages() async {
    try {
      final token = await _getToken();

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

  // 2. 💡 MENGIRIM PESAN BARU (BISA TEKS, GAMBAR, ATAU KEDUANYA)
  static Future<bool> sendMessage(String message, {File? imageFile}) async {
    try {
      final token = await _getToken();

      if (token == null) return false;

      // 💡 Kita gunakan MultipartRequest karena ada kemungkinan kirim file
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('${ApiConfig.baseUrl}/consultation')
      );

      // Set Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      // (Catatan: Content-Type tidak perlu di-set json lagi karena Multipart otomatis mengaturnya)

      // Tambahkan teks ke form-data (jika ada isinya)
      if (message.isNotEmpty) {
        request.fields['message'] = message;
      }

      // Tambahkan gambar ke form-data (jika ada file yang dipilih)
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Pastikan nama key ini sama dengan validasi di Laravel
            imageFile.path
          )
        );
      }

      // Kirim request ke server
      var response = await request.send();

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("====================================");
      print("🔴 ERROR KIRIM PESAN: $e");
      print("====================================");
      return false;
    }
  }
}