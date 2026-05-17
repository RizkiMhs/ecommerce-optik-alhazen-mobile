import 'package:flutter/material.dart';
import 'package:optik_alhazen_app/widgets/alhazen_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';
import '../services/product_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import '../widgets/promo_carousel.dart';
import '../widgets/custom_search_bar.dart'; // 💡 Tambahkan import ini

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];
  List filteredProducts =
      []; // 💡 Variabel baru untuk menampung hasil pencarian
  bool isLoading = true;
  String activeCategory = 'Semua';

  // 💡 Controller untuk membaca teks yang diketik di kotak pencarian
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void dispose() {
    _searchController
        .dispose(); // 💡 Jangan lupa dibuang saat layar ditutup agar tidak bocor memori
    super.dispose();
  }

  void loadProducts() async {
    try {
      final data = await ProductService.getProducts();
      if (mounted) {
        setState(() {
          products = data;
          filteredProducts =
              data; // 💡 Saat awal load, hasil pencarian = semua produk
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      if (mounted) setState(() => isLoading = false);
    }
  }

  // 💡 FUNGSI PENCARIAN BARU
  // 💡 FUNGSI PENCARIAN & KATEGORI DIPERBARUI
  void _runFilter() {
    List results = products;

    // 1. Filter berdasarkan kategori
    if (activeCategory != 'Semua') {
      results = results.where((product) {
        // Sesuaikan dengan nama kategori di database Anda (misal: 'pria', 'wanita', dll)
        final productCategory =
            product['category']?.toString().toLowerCase() ?? '';
        return productCategory == activeCategory.toLowerCase();
      }).toList();
    }

    // 2. Filter berdasarkan kata kunci pencarian
    String enteredKeyword = _searchController.text.toLowerCase();
    if (enteredKeyword.isNotEmpty) {
      results = results.where((product) {
        final productName = product['name'].toString().toLowerCase();
        return productName.contains(enteredKeyword);
      }).toList();
    }

    // Refresh layar
    setState(() {
      filteredProducts = results;
    });
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AlhazenAppBar(title: "Optik Alhazen"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. SEARCH BAR (KOLOM PENCARIAN) YANG SUDAH AKTIF ---
            // --- 1. SEARCH BAR (KOLOM PENCARIAN) YANG SUDAH AKTIF ---
            // --- 1. SEARCH BAR ---
            CustomSearchBar(
              controller: _searchController,
              onChanged: (value) => _runFilter(), // 💡 Diubah
              onClear: () {
                _searchController.clear();
                _runFilter(); // 💡 Diubah
                FocusScope.of(context).unfocus();
              },
            ),

            // --- 2. BANNER PROMO CAROUSEL ---
            const PromoCarousel(),
            const SizedBox(height: 24),

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
                // Text("Lihat Semua",
                //     style: TextStyle(
                //         fontSize: 13,
                //         color: Colors.blue[700],
                //         fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            // --- 3. KATEGORI ---
            // ...
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  CategoryItem(
                      label: "Semua",
                      icon: Icons.apps_rounded,
                      isActive: activeCategory == "Semua",
                      onTap: () {
                        setState(() => activeCategory = "Semua");
                        _runFilter();
                      }),
                  CategoryItem(
                      label: "Pria",
                      icon: Icons.face_retouching_natural,
                      isActive: activeCategory == "Pria",
                      onTap: () {
                        setState(() => activeCategory = "Pria");
                        _runFilter();
                      }),
                  CategoryItem(
                      label: "Wanita",
                      icon: Icons.face_3_rounded,
                      isActive: activeCategory == "Wanita",
                      onTap: () {
                        setState(() => activeCategory = "Wanita");
                        _runFilter();
                      }),
                  CategoryItem(
                      label: "Unisex",
                      icon: Icons.people_alt_outlined,
                      isActive: activeCategory == "Unisex",
                      onTap: () {
                        setState(() => activeCategory = "Unisex");
                        _runFilter();
                      }),
                  CategoryItem(
                      label: "Aksesoris",
                      icon: Icons.watch_outlined,
                      isActive: activeCategory == "Aksesoris",
                      onTap: () {
                        setState(() => activeCategory = "Aksesoris");
                        _runFilter();
                      }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 4. PRODUK ---
            const Text(
              "Rekomendasi Produk",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12),

            isLoading
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFF3F51B5)),
                  ))
                : filteredProducts
                        .isEmpty // 💡 Cek apakah array hasil pencariannya kosong
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                "Produk tidak ditemukan",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts
                            .length, // 💡 Gunakan filteredProducts
                        itemBuilder: (context, index) {
                          final product = filteredProducts[
                              index]; // 💡 Gunakan filteredProducts
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
