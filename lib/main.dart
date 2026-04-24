import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:optik_alhazen_app/screens/register_screen.dart';
import 'package:optik_alhazen_app/screens/splash_screen.dart';
import 'dart:convert';
import 'screens/login_screen.dart';

void main() => runApp(const OptikApp());

class OptikApp extends StatelessWidget {
  const OptikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Warna dasar biru
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   // Controller untuk mengambil teks dari inputan
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmController = TextEditingController();

//   // Fungsi untuk mengirim data ke Laravel API
//   Future<void> _register() async {
//     // Ganti IP ini dengan IP laptop Anda (bukan localhost jika pakai emulator HP asli)
//     // Contoh: http://192.168.1.5:8000/api/register
//     final url = Uri.parse('http://10.41.251.133:8000/api/register');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json'
//         },
//         body: jsonEncode({
//           'name': _nameController.text,
//           'email': _emailController.text,
//           'password': _passwordController.text,
//           'password_confirmation': _confirmController.text,
//         }),
//       );

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Registrasi Berhasil!'),
//               backgroundColor: Colors.green),
//         );
//       } else {
//         final error = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Gagal: ${error.toString()}'),
//               backgroundColor: Colors.red),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Tidak bisa terhubung ke server'),
//             backgroundColor: Colors.red),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue[50], // Background biru muda sangat lembut
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 80),
//             const Icon(Icons.remove_red_eye, size: 80, color: Colors.blue),
//             const SizedBox(height: 10),
//             const Text(
//               "Optik Alhazen",
//               style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue),
//             ),
//             const Text("Pendaftaran Akun Baru"),
//             const SizedBox(height: 40),

//             // --- Input Fields ---
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                   labelText: "Nama Lengkap", border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                   labelText: "Email", border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                   labelText: "Password", border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _confirmController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                   labelText: "Konfirmasi Password",
//                   border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 30),

//             // --- Tombol Register ---
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _register,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text("DAFTAR SEKARANG",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
