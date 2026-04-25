import 'dart:convert';
import 'package:http/http.dart' as http;

class BiteshipService {
  // 💡 Ganti dengan API Key Testing Biteship Anda
  static const String apiKey = 'biteship_test.eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoib3B0aWtfYWxoYXplbiIsInVzZXJJZCI6IjY5ZGExMWUwOTAxZmMyNjU2ODRmZDdhYiIsImlhdCI6MTc3NzAzNzg0OH0.nKH5fDEFpXxSbsJ-HL12BZdu2BBrdwBQfgR-7OJv2Xg';

  static Future<List<dynamic>> cekOngkir({
    required int originPostalCode,
    required int destinationPostalCode,
    required String kurir,
  }) async {
    final url = Uri.parse('https://api.biteship.com/v1/rates/couriers');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "origin_postal_code": originPostalCode,
        "destination_postal_code": destinationPostalCode,
        "couriers": kurir,
        "items": [
          {
            "name": "Kacamata",
            "weight": 500, // Asumsi berat 500 gram (Sama dengan di backend)
            "value": 100000 
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pricing'] ?? [];
    } else {
      // 💡 TAMBAHKAN BARIS INI UNTUK MELIHAT ALASAN ASLI PENOLAKAN BITESHIP
      print("🚨 RESPONS ASLI BITESHIP: ${response.body}");
      
      throw Exception('Gagal: ${response.statusCode}');
    }
  }
}