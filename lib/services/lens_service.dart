import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class LensService {
  static Future<List<Map<String, dynamic>>> getLensOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/lens-types'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((item) {
        return {
          'id': item['id'],
          'name': item['lens_name'],
          'price': double.tryParse(item['additional_price'].toString()) ?? 0,
        };
      }).toList();
    }
    return [];
  }
}