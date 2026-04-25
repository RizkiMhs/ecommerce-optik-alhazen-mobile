// lib/config/api_config.dart

class ApiConfig {
  // URL dasar API Anda
  static const String baseUrl = 'http://10.152.154.133:8000/api';

  // Daftar endpoint API yang digunakan
  static const String registerEndpoint = '${baseUrl}/register';
  static const String loginEndpoint = '${baseUrl}/login';
  static const String getUserEndpoint = '${baseUrl}/user';
  static const String profileEndpoint = '${baseUrl}/profile';
  static const String addressesEndpoint = '${baseUrl}/addresses';
  // Tambahkan endpoint lain sesuai kebutuhan
}
