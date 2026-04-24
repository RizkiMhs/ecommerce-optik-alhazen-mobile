import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../navigation/main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final AuthController _auth = AuthController();

  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);

    bool success = await _auth.login(
      _email.text.trim(),
      _password.text.trim(),
    );

    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email atau password salah"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang putih bersih atau sedikit kebiruan sesuai referensi
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
              children: [
                // --- BAGIAN LOGO ---
                Center(
                  child: Column(
                    children: [
                      // TODO: GANTI DENGAN LOGO OPTIK ALHAZEN
                      // Gunakan Image.asset('assets/logo.png', height: 60) jika sudah ada gambar
                      // Icon(Icons.visibility_outlined,
                      //     size: 60, color: Color(0xFF1E3A8A)),
                      Image.asset(
                        'assets/images/logo.png', // Sesuaikan dengan nama file Anda
                        height: 100, // Atur tinggi logo sesuai selera
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Optik Alhazen",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E3A8A), // Biru gelap
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // --- TEKS JUDUL ---
                const Text(
                  "Login to your Account",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // --- TEXTFIELD EMAIL ---
                _buildModernTextField(
                  controller: _email,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                // --- TEXTFIELD PASSWORD ---
                _buildModernTextField(
                  controller: _password,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                // --- TOMBOL LOGIN ---
                _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF1E3A8A)))
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFF243B9B), // Biru gelap sesuai referensi
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: Colors.blue.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Sign in",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                const SizedBox(height: 40),

                // --- TOMBOL REGISTER BAWAH ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xFF243B9B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER TEXTFIELD ---
  // Membuat kolom input polos, bersih, dan membulat tanpa ikon
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF243B9B), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  // --- WIDGET HELPER SOCIAL BUTTON ---
  Widget _buildSocialButton(String label, Color color, {required bool isIcon}) {
    return Container(
      width: 65,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: isIcon
            ? Icon(Icons.abc, color: color) // Placeholder jika pakai IconData
            : Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
      ),
    );
  }
}
