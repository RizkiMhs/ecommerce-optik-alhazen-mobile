import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class VoucherService {
  // Ambil daftar voucher
  static Future<List<dynamic>> getAvailableVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/vouchers"),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['data'];
      }
      return [];
    } catch (e) {
      print("Error fetching vouchers: $e");
      return [];
    }
  }

  // Verifikasi dan hitung diskon voucher
  static Future<Map<String, dynamic>> verifyVoucher(String code, double totalBelanja) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/vouchers/verify"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'code': code,
          'total_belanja': totalBelanja,
        }),
      );

      final decoded = jsonDecode(res.body);
      return decoded; 
    } catch (e) {
      print("Error verify voucher: $e");
      return {'status': 'error', 'message': 'Terjadi kesalahan jaringan.'};
    }
  }
}