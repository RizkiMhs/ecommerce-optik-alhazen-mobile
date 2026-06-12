import 'package:flutter/material.dart';
import 'package:optik_alhazen_app/navigation/main_navigation.dart';
import '../controllers/auth_controller.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _auth = AuthController();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    await Future.delayed(Duration(seconds: 2)); // delay biar smooth

    bool isLoggedIn = await _auth.isLoggedIn();

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, const Color.fromRGBO(216, 199, 199, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- BAGIAN YANG DIUBAH ---
              // Memanggil gambar logo toko dari folder assets
              Image.asset(
                'assets/images/logo.png', // Pastikan nama file dan path-nya sesuai
                width: 120, // Kamu bisa menyesuaikan ukuran lebarnya di sini
                height: 120, // Kamu bisa menyesuaikan ukuran tingginya di sini
              ),
              // --------------------------
              SizedBox(height: 5),
              Text(
                "Optik Alhazen",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                  color: const Color.fromARGB(255, 66, 0, 221)),
            ],
          ),
        ),
      ),
    );
  }
}
