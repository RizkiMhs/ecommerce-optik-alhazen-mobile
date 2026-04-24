// 

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  static Future<List<dynamic>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/products"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // 🔥 penting kalau pakai sanctum
        },
      );

      // (Opsional) Bisa dihapus kalau aplikasi sudah rilis agar console tidak penuh
      // print("STATUS: ${res.statusCode}");
      // print("BODY: ${res.body}");

      if (res.statusCode == 200) {
        final decodedData = jsonDecode(res.body);
        
        // 💡 PERBAIKAN: Kita ambil value dari key 'data'
        // Cek dulu apakah API mengembalikan format baru ('data') atau format lama (array langsung)
        if (decodedData is Map && decodedData.containsKey('data')) {
          return decodedData['data'];
        } else if (decodedData is List) {
          return decodedData; // Jaga-jaga jika API masih pakai format lama
        } else {
          return [];
        }

      } else {
        print("Gagal mengambil produk. Status: ${res.statusCode}");
        return []; // 🔥 biar tidak crash
      }
    } catch (e) {
      // 💡 PERBAIKAN: Tangkap error jika tidak ada internet / server mati
      print("Error jaringan saat mengambil produk: $e");
      return []; 
    }
  }
}