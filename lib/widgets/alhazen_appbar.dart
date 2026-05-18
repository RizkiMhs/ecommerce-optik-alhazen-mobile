import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 Import SharedPreferences
import 'package:optik_alhazen_app/screens/cart_screen.dart';
// 💡 Sesuaikan import ini dengan lokasi file LoginScreen Anda:
// import 'package:optik_alhazen_app/screens/login_screen.dart';

class AlhazenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCart;

  const AlhazenAppBar({Key? key, required this.title, this.showCart = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF3F51B5),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // --- TOMBOL CART ---
        if (showCart)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              icon: const Badge(
                label: Text('!'), // Nanti bisa dihubungkan ke Stream/Provider
                child: Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),

        // --- 💡 TOMBOL LOGOUT DARURAT ---
        // Padding(
        //   padding: const EdgeInsets.only(right: 10),
        //   child: IconButton(
        //     tooltip: "Logout Darurat",
        //     icon: const Icon(Icons.logout_rounded,
        //         color: Colors.redAccent), // Warna merah agar mudah terlihat
        //     onPressed: () => _showLogoutDialog(context),
        //   ),
        // ),
      ],
    );
  }

  // 💡 FUNGSI LOGOUT (Menghapus data & kembali ke halaman Login)
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Darurat'),
          content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi? Semua sesi akan dihapus.'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                // 1. Hapus token dari SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Menghapus semua data sesi

                // 2. Arahkan ke LoginScreen dan hapus semua riwayat halaman (agar tidak bisa di-back)
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      // 💡 GANTI "LoginScreen()" dengan nama class halaman login Anda
                      builder: (context) => const Scaffold(
                          body: Center(child: Text("Halaman Login"))),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
