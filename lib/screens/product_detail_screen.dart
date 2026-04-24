import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

// Sesuaikan dengan path project kamu
import 'package:optik_alhazen_app/config/api_config.dart';
import 'package:optik_alhazen_app/services/lens_service.dart';
import 'package:optik_alhazen_app/services/cart_service.dart';
import 'package:optik_alhazen_app/widgets/alhazen_appbar.dart'; // 🔥 IMPORT CART SERVICE

class ProductDetailScreen extends StatefulWidget {
  final Map product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // --- STATE UNTUK PILIHAN LENSA ---
  List<Map<String, dynamic>> lensOptions = [];
  Map<String, dynamic>? selectedLens;

  // --- STATE UNTUK RESEP MATA ---
  final TextEditingController _sphRightCtrl = TextEditingController();
  final TextEditingController _cylRightCtrl = TextEditingController();
  final TextEditingController _sphLeftCtrl = TextEditingController();
  final TextEditingController _cylLeftCtrl = TextEditingController();
  final TextEditingController _pdCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  // 🔥 STATE UNTUK LOADING TOMBOL KERANJANG
  bool _isLoading = false;

  @override
  void dispose() {
    // Jangan lupa bersihkan memory saat keluar layar
    _sphRightCtrl.dispose();
    _cylRightCtrl.dispose();
    _sphLeftCtrl.dispose();
    _cylLeftCtrl.dispose();
    _pdCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadLensOptions();
  }

  void loadLensOptions() async {
    final options = await LensService.getLensOptions();
    setState(() {
      lensOptions = options;
      if (lensOptions.isNotEmpty) selectedLens = lensOptions[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- SETUP GAMBAR ---
    final List<String> images = [];
    
    // 💡 SOLUSI: Kita hilangkan kata '/api' dari baseUrl khusus untuk gambar
    final String serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    
    // 1. Prioritas Utama: Ambil semua gambar dari relasi 'images'
    if (widget.product['images'] != null && widget.product['images'].isNotEmpty) {
      for (var img in widget.product['images']) {
        if (img['image_name'] != null && img['image_name'].toString().isNotEmpty) {
          // Gunakan serverUrl yang sudah bersih dari kata '/api'
          images.add("$serverUrl/storage/${img['image_name']}");
        }
      }
    } 
    // 2. Fallback: Jika relasi 'images' kosong, gunakan 'image_url' (gambar utama)
    else if (widget.product['image_url'] != null && widget.product['image_url'].toString().isNotEmpty) {
      // image_url dari Laravel biasanya sudah berbentuk URL lengkap yang benar
      images.add(widget.product['image_url']);
    }

    // --- KALKULASI HARGA ---
    double basePrice =
        double.tryParse(widget.product['base_price'].toString()) ?? 0;
    double lensPrice = selectedLens?['price'] ?? 0;
    double totalPrice = basePrice + lensPrice;

    String formatRupiah(double value) {
      return "Rp ${value.toStringAsFixed(0)}";
    }

    // Pengecekan kategori produk
    bool isEyewear = widget.product['category'] != 'aksesoris';

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text(widget.product['name'] ?? 'Detail Produk'),
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      // ),

      appBar: const AlhazenAppBar(title: "Detail Produk"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. SLIDER GAMBAR ---
            if (images.isNotEmpty)
              CarouselSlider(
                items: images.map((url) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  size: 50, color: Colors.grey),
                            );
                          },
                        ),
                      );
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 0.9,
                  enlargeCenterPage: true,
                  autoPlay: true,
                ),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey)),
              ),

            const SizedBox(height: 20),

            // --- 2. INFO PRODUK UTAMA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'] ?? 'Nama Produk Tidak Tersedia',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(totalPrice),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF3F51B5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. SEKSI PILIH LENSA & RESEP (HANYA MUNCUL JIKA BUKAN AKSESORIS) ---
            if (isEyewear) ...[
              // Seksi Pilih Lensa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pilih Lensa",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lensOptions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final lens = lensOptions[index];
                        final isSelected = selectedLens?['id'] == lens['id'];

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedLens = lens;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blueAccent
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.05)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lens['name'],
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.blueAccent
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (lens['price'] > 0) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        "+ ${formatRupiah(lens['price'])}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600),
                                      ),
                                    ]
                                  ],
                                ),
                                Radio<int>(
                                  value: lens['id'],
                                  groupValue: selectedLens?['id'],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLens = lens;
                                    });
                                  },
                                  activeColor: Colors.blueAccent,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Seksi Input Resep
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Resep Kacamata (Opsional)",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.03),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                  width: 40,
                                  child: Text("R (Kanan)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: TextField(
                                      controller: _sphRightCtrl,
                                      decoration: const InputDecoration(
                                          labelText: "SPH (Min/Plus)",
                                          isDense: true))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: TextField(
                                      controller: _cylRightCtrl,
                                      decoration: const InputDecoration(
                                          labelText: "CYL (Silinder)",
                                          isDense: true))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const SizedBox(
                                  width: 40,
                                  child: Text("L (Kiri)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: TextField(
                                      controller: _sphLeftCtrl,
                                      decoration: const InputDecoration(
                                          labelText: "SPH (Min/Plus)",
                                          isDense: true))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: TextField(
                                      controller: _cylLeftCtrl,
                                      decoration: const InputDecoration(
                                          labelText: "CYL (Silinder)",
                                          isDense: true))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: TextField(
                                      controller: _pdCtrl,
                                      decoration: const InputDecoration(
                                          labelText: "PD (Jarak Pupil)",
                                          isDense: true))),
                              const SizedBox(width: 10),
                              Expanded(
                                  flex: 2,
                                  child: TextField(
                                      controller: _noteCtrl,
                                      decoration: const InputDecoration(
                                          labelText: "Catatan Tambahan",
                                          isDense: true))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // --- 4. DESKRIPSI PRODUK ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Deskripsi",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['description'] ?? 'Tidak ada deskripsi',
                    style: const TextStyle(height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // --- 5. TOMBOL BELI (TERHUBUNG KE API) ---
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            // 🔥 LOGIKA KETIKA TOMBOL DITEKAN
            onPressed: _isLoading
                ? null // Matikan tombol jika sedang loading
                : () async {
                    setState(() {
                      _isLoading = true; // Nyalakan loading
                    });

                    // 1. Siapkan data yang mau dikirim ke Laravel
                    final Map<String, dynamic> payloadKeranjang = {
                      'product_id': widget.product['id'],
                      'qty': 1, // Default pesannya 1
                      // Jika aksesoris, lens_type_id dikosongkan (null)
                      // 'lens_type_id': isEyewear ? selectedLens?['id'] : null,
                      'lens_type_id': selectedLens?[
                          'id'], // Jika null, Laravel akan anggap tidak pilih lensa

                      // Data Resep
                      'sph_right': _sphRightCtrl.text,
                      'cyl_right': _cylRightCtrl.text,
                      'sph_left': _sphLeftCtrl.text,
                      'cyl_left': _cylLeftCtrl.text,
                      'pd': _pdCtrl.text,
                      'note': _noteCtrl.text,
                    };

                    // 2. Panggil API lewat CartService
                    bool success =
                        await CartService.addToCart(payloadKeranjang);

                    // 3. Matikan loading
                    setState(() {
                      _isLoading = false;
                    });

                    // 4. Cek hasil dan beri notifikasi
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Berhasil dimasukkan ke keranjang! 🛒'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Opsional: Kembali ke halaman sebelumnya
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Gagal memasukkan ke keranjang. Coba lagi.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
            // 🔥 TAMPILAN TOMBOL (Teks atau Loading berputar)
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    "Masukkan Keranjang",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}
