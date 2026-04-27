import 'package:flutter/material.dart';
import 'package:optik_alhazen_app/widgets/alhazen_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';
import '../services/product_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import '../widgets/promo_carousel.dart'; // 💡 IMPORT BARU

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    try {
      final data = await ProductService.getProducts();
      if (mounted) {
        setState(() {
          products = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFF8F9FA), // 💡 Background abu-abu sangat muda agar card lebih menonjol
      appBar: const AlhazenAppBar(title: "Optik Alhazen"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // 💡 Animasi scroll lebih halus
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. SEARCH BAR (KOLOM PENCARIAN) BARU ---
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Cari kacamata favoritmu...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF3F51B5)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            // --- 2. BANNER PROMO YANG DIPERBARUI ---
            // --- 2. BANNER PROMO CAROUSEL ---
            const PromoCarousel(),
            // const SizedBox(height: 16),
            const SizedBox(height: 24), // 💡 Spacing diperlebar sedikit

            // --- 3. KATEGORI ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Kategori",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                Text("Lihat Semua",
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  CategoryItem(
                      label: "Semua",
                      icon: Icons.apps_rounded,
                      isActive: true,
                      onTap: () {}),
                  CategoryItem(
                      label: "Pria",
                      icon: Icons.face_retouching_natural,
                      isActive: false,
                      onTap: () {}),
                  CategoryItem(
                      label: "Wanita",
                      icon: Icons.face_3_rounded,
                      isActive: false,
                      onTap: () {}),
                  CategoryItem(
                      label: "Unisex",
                      icon: Icons.people_alt_outlined,
                      isActive: false,
                      onTap: () {}),
                  CategoryItem(
                      label: "Aksesoris",
                      icon: Icons.watch_outlined,
                      isActive: false,
                      onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 24), // 💡 Spacing diperlebar

            // --- 4. PRODUK ---
            const Text(
              "Rekomendasi Produk",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // List Produk Tetap Sama (Menunggu perbaikan di produk_widget.dart)
            isLoading
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF3F51B5)),
                  ))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }
}
