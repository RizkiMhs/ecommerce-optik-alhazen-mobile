import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optik_alhazen_app/screens/cart_screen.dart';
import '../services/cart_service.dart'; // Import CartService

// Ganti import ini dengan lokasi LoginScreen Anda jika fungsi logout darurat diaktifkan
// import 'package:optik_alhazen_app/screens/login_screen.dart';

class AlhazenAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showCart;

  const AlhazenAppBar({Key? key, required this.title, this.showCart = true})
      : super(key: key);

  @override
  State<AlhazenAppBar> createState() => _AlhazenAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AlhazenAppBarState extends State<AlhazenAppBar> {
  int _cartItemCount = 0; // Variabel untuk menyimpan jumlah barang di keranjang

  @override
  void initState() {
    super.initState();
    if (widget.showCart) {
      _fetchCartCount();
    }
  }

  // 💡 FUNGSI: Mengambil jumlah barang di keranjang dari API
  Future<void> _fetchCartCount() async {
    try {
      final carts = await CartService.getCartItems();
      if (mounted) {
        setState(() {
          _cartItemCount = carts.length;
        });
      }
    } catch (e) {
      print("Error fetch cart count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF3F51B5),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // --- TOMBOL CART ---
        if (widget.showCart)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              icon: Badge(
                isLabelVisible: _cartItemCount > 0, // Hanya muncul jika > 0
                label: Text(_cartItemCount.toString()),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () async {
                // Tunggu sampai user kembali dari halaman keranjang
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
                // Refresh angka keranjang
                _fetchCartCount();
              },
            ),
          ),

        // --- TOMBOL LOGOUT DARURAT (Silakan di-uncomment jika ingin digunakan) ---
        /*
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            tooltip: "Logout Darurat",
            icon: const Icon(Icons.logout_rounded,
                color: Colors.redAccent), // Warna merah agar mudah terlihat
            onPressed: () => _showLogoutDialog(context),
          ),
        ),
        */
      ],
    );
  }

  // 💡 FUNGSI LOGOUT DARURAT (Menghapus data & kembali ke halaman Login)
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
                      // 💡 GANTI dengan nama class halaman login Anda
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
}
