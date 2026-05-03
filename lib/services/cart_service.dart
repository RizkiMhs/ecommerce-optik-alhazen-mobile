import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // GET: Ambil data keranjang
  static Future<List<dynamic>> getCartItems() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/cart"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }
    return [];
  }

  // UPDATE: Ubah QTY di server
  static Future<void> updateQty(int cartId, int newQty) async {
    final token = await _getToken();
    await http.put(
      Uri.parse("${ApiConfig.baseUrl}/cart/$cartId"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {'qty': newQty.toString()},
    );
  }

  // DELETE: Hapus item
  static Future<void> deleteItem(int cartId) async {
    final token = await _getToken();
    await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/cart/$cartId"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  // --- 2. FUNGSI UNTUK MENAMBAH KE KERANJANG (POST) ---
  static Future<bool> addToCart(Map<String, dynamic> dataKeranjang) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/cart"),
      headers: {
        'Content-Type': 'application/json', // 🔥 Wajib untuk POST data JSON
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dataKeranjang),
    );

    print("ADD CART STATUS: ${res.statusCode}");
    print("ADD CART BODY: ${res.body}");

    // Laravel mengembalikan 201 Created atau 200 OK jika sukses
    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    } else {
      return false; 
    }
  }
}