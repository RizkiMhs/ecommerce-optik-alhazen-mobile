import 'package:flutter/material.dart';
import 'package:optik_alhazen_app/widgets/alhazen_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/category_item.dart';
import '../widgets/product_card.dart';
import '../services/product_service.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';

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
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
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
      // appBar: AppBar(
      //   title: const Text('Home'),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(icon: const Icon(Icons.person), onPressed: _goToProfile),
      //     IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
      //   ],
      // ),
      appBar: const AlhazenAppBar(title: "Optik Alhazen"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "Promo Kacamata!",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Di dalam Column di HomeScreen Anda:

            const Text(
              "Kategori",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics:
                  const BouncingScrollPhysics(), // Efek pantul iOS yang halus
              child: Row(
                children: [
                  CategoryItem(
                    label: "Semua",
                    isActive: true, // Contoh yang sedang aktif
                    onTap: () {},
                  ),
                  CategoryItem(
                    label: "Pria",
                    isActive: false,
                    onTap: () {},
                  ),
                  CategoryItem(
                    label: "Wanita",
                    isActive: false,
                    onTap: () {},
                  ),
                  CategoryItem(
                    label: "Unisex",
                    isActive: false,
                    onTap: () {},
                  ),
                  CategoryItem(
                    label: "Aksesoris",
                    isActive: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Produk",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Ganti GridView.builder yang lama dengan kodingan ini:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    // 💡 Gunakan ListView agar satu baris satu card
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        // 💡 Widget ProductCard yang baru (Horizontal)
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
