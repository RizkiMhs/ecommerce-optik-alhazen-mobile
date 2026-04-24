import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class OrderService {
  // --- Fungsi Cek Ongkir ---
  static Future<Map<String, dynamic>?> checkOngkir(String destinationCityId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/ongkir"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'destination_city_id': destinationCityId,
        },
      );

      // 💡 TAMBAHKAN 3 BARIS INI UNTUK DEBUGGING
      print("=== DEBUG ONGKIR ===");
      print("Status Code: ${res.statusCode}");
      print("Body Balasan: ${res.body}");
      print("====================");

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      print("Error saat mengambil ongkir: $e");
      return null;
    }
  }


  // 💡 FUNGSI BARU: Mengirim data Checkout ke Laravel
  static Future<Map<String, dynamic>> submitOrder({
    required double shippingCost,
    required String courier,
    required String paymentMethod,
    required Map<String, dynamic> addressData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // 💡 1. KITA BUNGKUS DATANYA DULU
    final requestBody = {
      "shipping_cost": shippingCost,
      "courier": courier,
      "payment_method": paymentMethod, 
      "recipient_name": addressData['recipient_name'],
      "phone": addressData['phone'],
      "full_address": "${addressData['complete_address']}, Kode Pos: ${addressData['postal_code']}",
    };

    // 💡 2. CETAK KE CONSOLE FLUTTER
    print("====== DATA DARI FLUTTER ======");
    print(jsonEncode(requestBody));
    print("===============================");

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/checkout'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "shipping_cost": shippingCost,
          "courier": courier,
          "payment_method": paymentMethod, // Jika di Laravel belum ada tangkapan ini, tambahkan ya
          "recipient_name": addressData['recipient_name'],
          "phone": addressData['phone'],
          "full_address": "${addressData['complete_address']}, Kode Pos: ${addressData['postal_code']}",
        }),
      );

      return jsonDecode(res.body);
    } catch (e) {
      print("Error submit order: $e");
      return {'status': 'error', 'message': 'Terjadi kesalahan jaringan'};
    }
  }


  // 💡 FUNGSI BARU: Mengambil daftar pesanan dari Laravel
  static Future<List<dynamic>> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data']; // Mengembalikan array pesanan
      } else {
        print("Gagal mengambil pesanan: ${res.body}");
        return [];
      }
    } catch (e) {
      print("Error fetch orders: $e");
      return [];
    }
  }
}