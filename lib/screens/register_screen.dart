import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final AuthController _auth = AuthController();
  bool _loading = false;

  void _register() async {
    setState(() => _loading = true);

    bool success = await _auth.register(
      _name.text.trim(),
      _email.text.trim(),
      _password.text.trim(),
    );

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Register berhasil, silakan login"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Register gagal, periksa kembali data Anda"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FE), // Warna background sama dengan Login
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN LOGO ---
                Center(
                  child: Column(
                    children: [
                      // Memanggil logo yang sudah Anda daftarkan di assets
                      Image.asset(
                        'assets/images/logo.png',
                        height: 60,
                        // Menambahkan errorBuilder jaga-jaga jika gambar gagal dimuat
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.visibility_outlined,
                                size: 60, color: Color(0xFF1E3A8A)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Optik Alhazen",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // --- TEKS JUDUL ---
                const Text(
                  "Create an Account",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // --- TEXTFIELD NAMA ---
                _buildModernTextField(
                  controller: _name,
                  hintText: "Full Name",
                  obscureText: false,
                ),
                const SizedBox(height: 16),

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

                // --- TOMBOL REGISTER ---
                _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF1E3A8A)))
                    : SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF243B9B),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: Colors.blue.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                const SizedBox(height: 40),

                // --- TOMBOL KEMBALI KE LOGIN ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Sign in",
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
}
