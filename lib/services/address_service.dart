import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AddressService {
  static Future<List<dynamic>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final res = await http.get(
        // Pastikan route API Laravel Anda adalah /api/addresses
        Uri.parse("${ApiConfig.baseUrl}/addresses"), 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        // Karena controller Anda langsung me-return: return $request->user()->addresses;
        return jsonDecode(res.body); 
      }
      return [];
    } catch (e) {
      print("Error fetch addresses: $e");
      return [];
    }
  }
}