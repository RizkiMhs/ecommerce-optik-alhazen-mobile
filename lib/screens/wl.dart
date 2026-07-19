import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/product_card.dart'; // Sesuaikan path jika berbeda
import '../services/product_service.dart'; // Sesuaikan dengan service pemanggil produk Anda
import 'product_detail_screen.dart'; // Sesuaikan path halaman detail produk

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<dynamic> wishlistProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => isLoading = true);

    // 1. Ambil daftar ID yang disukai dari memori lokal (HP)
    final prefs = await SharedPreferences.getInstance();
    List<String> savedIds = prefs.getStringList('wishlist') ?? [];

    // 2. Ambil SEMUA produk dari API (seperti di halaman Home)
    // 💡 CATATAN: Ganti 'ProductService.getProducts()' sesuai dengan fungsi API Anda
    final allProducts = await ProductService.getProducts(); 

    // 3. Filter! Hanya tampilkan produk yang ID-nya ada di dalam savedIds
    if (mounted) {
      setState(() {
        wishlistProducts = allProducts
            .where((product) => savedIds.contains(product['id'].toString()))
            .toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3F51B5)),
        title: const Text(
          "Wishlist Saya",
          style: TextStyle(
            color: Color(0xFF3F51B5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
          : wishlistProducts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: wishlistProducts.length,
                  itemBuilder: (context, index) {
                    final product = wishlistProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () async {
                        // Navigasi ke detail, dan refresh wishlist saat kembali
                        // (Berjaga-jaga jika user meng-unlike produk di halaman detail)
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product),
                          ),
                        );
                        _loadWishlist(); // Refresh list
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada produk favorit",
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Produk yang Anda sukai akan muncul di sini.",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}