import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'dart:io';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/profile"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/addresses"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    // 🔥 HANDLE KOSONG
    if (res.body.isEmpty) {
      return [];
    }

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return data is List ? data : data['data'] ?? [];
    } else {
      throw Exception(data['message'] ?? 'Gagal ambil alamat');
    }
  }

  // tambah address
  static Future<bool> addAddress(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/addresses"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> updateAddress(int id, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/addresses/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  }

  static Future<bool> deleteAddress(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/addresses/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    return res.statusCode == 200;
  }

  static Future<List<dynamic>> searchCities(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cities?search=$query'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 💡 TAMBAHKAN DEBUG LOG DI SINI
      print("=== DEBUG SEARCH CITY ===");
      print("URL: ${ApiConfig.baseUrl}/cities?search=$query");
      print("Status Code: ${res.statusCode}");
      print("Body Balasan: ${res.body}");
      print("=========================");

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['status'] == 'success') {
          return json['data']; 
        }
      }
      return [];
    } catch (e) {
      print("Error search cities: $e");
      return [];
    }
  }

  // 💡 FUNGSI BARU: Mengganti Password
  // 💡 FUNGSI UPDATE PASSWORD YANG DIPERBARUI
  static Future<bool> updatePassword(String currentName, String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/profile"), 
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          '_method': 'PUT', 
          'name': currentName, 
          'old_password': oldPassword, // 💡 Kirim password lama
          'password': newPassword,     // 💡 Kirim password baru
        }),
      );

      // Jika status 200 berarti berhasil, jika 400 (password lama salah) berarti gagal
      return res.statusCode == 200;
    } catch (e) {
      print("Error update password: $e");
      return false;
    }
  }

  // 💡 FUNGSI BARU: Update Profil (Nama, Email, Password, Foto) dengan Multipart
  static Future<bool> updateFullProfile({
    required String name,
    required String email,
    String? phone,
    String? oldPassword,
    String? newPassword,
    File? avatarFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    try {
      // Karena Laravel REST API biasanya strict dengan PUT untuk multipart form-data, 
      // cara teraman adalah menggunakan metode POST lalu menambahkan field '_method': 'PUT'
      var request = http.MultipartRequest('POST', Uri.parse("${ApiConfig.baseUrl}/profile"));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Tambahkan field teks
      request.fields['_method'] = 'PUT'; // Triks Laravel
      request.fields['name'] = name;
      request.fields['email'] = email;

      // 💡 TAMBAHAN BARU: Kirim phone ke server jika ada
      if (phone != null) {
        request.fields['phone'] = phone;
      }
      
      if (oldPassword != null && oldPassword.isNotEmpty) {
        request.fields['old_password'] = oldPassword;
      }
      if (newPassword != null && newPassword.isNotEmpty) {
        request.fields['password'] = newPassword;
      }

      // Tambahkan file gambar jika ada
      if (avatarFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
        ));
      }

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      print("UPDATE PROFILE STATUS: ${res.statusCode}");
      print("UPDATE PROFILE BODY: ${res.body}");

      return res.statusCode == 200;
    } catch (e) {
      print("Error update full profile: $e");
      return false;
    }
  }
}

