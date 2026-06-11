import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // Untuk File (gambar resep)

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
  static Future<bool> addToCart(Map<String, dynamic> dataKeranjang, {File? imageFile}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    var request = http.MultipartRequest('POST', Uri.parse("${ApiConfig.baseUrl}/cart"));
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Masukkan semua data teks ke dalam request.fields
    dataKeranjang.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        request.fields[key] = value.toString();
      }
    });

    // Masukkan file gambar jika ada
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'prescription_image',
        imageFile.path,
      ));
    }

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    print("ADD CART STATUS: ${res.statusCode}");
    print("ADD CART BODY: ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    } else {
      return false; 
    }
  }
}