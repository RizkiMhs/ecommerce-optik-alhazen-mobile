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
            colors: [Colors.blue, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.remove_red_eye, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Optik Alhazen",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}