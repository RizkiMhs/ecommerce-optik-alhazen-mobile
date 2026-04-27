import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

// Sesuaikan dengan path project kamu
import 'package:optik_alhazen_app/config/api_config.dart';
import 'package:optik_alhazen_app/screens/cart_screen.dart';
import 'package:optik_alhazen_app/services/lens_service.dart';
import 'package:optik_alhazen_app/services/cart_service.dart';

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

  // STATE UNTUK INDIKATOR CAROUSEL GAMBAR
  int _currentImageIndex = 0;

  // --- STATE UNTUK RESEP MATA ---
  final TextEditingController _sphRightCtrl = TextEditingController();
  final TextEditingController _cylRightCtrl = TextEditingController();
  final TextEditingController _sphLeftCtrl = TextEditingController();
  final TextEditingController _cylLeftCtrl = TextEditingController();
  final TextEditingController _pdCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  // STATE UNTUK LOADING TOMBOL KERANJANG
  bool _isLoading = false;

  @override
  void dispose() {
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
    });
  }

  String formatRupiah(dynamic amount) {
    double parsedAmount = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(parsedAmount);
  }

  @override
  Widget build(BuildContext context) {
    // --- SETUP GAMBAR ---
    final List<String> images = [];
    final String serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    if (widget.product['images'] != null &&
        widget.product['images'].isNotEmpty) {
      for (var img in widget.product['images']) {
        if (img['image_name'] != null &&
            img['image_name'].toString().isNotEmpty) {
          images.add("$serverUrl/storage/${img['image_name']}");
        }
      }
    } else if (widget.product['image_url'] != null &&
        widget.product['image_url'].toString().isNotEmpty) {
      images.add(widget.product['image_url']);
    }

    // --- KALKULASI HARGA ---
    double basePrice =
        double.tryParse(widget.product['base_price'].toString()) ?? 0;
    double lensPrice = selectedLens?['price'] ?? 0;
    double totalPrice = basePrice + lensPrice;

    bool isEyewear = widget.product['category'] != 'aksesoris';

    return Scaffold(
      backgroundColor: Colors.white,

      // 💡 APP BAR BARU SESUAI REFERENSI GAMBAR
      // 💡 APP BAR BARU SESUAI REFERENSI GAMBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detail Produk",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100, // Background bulat abu-abu
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100, // Background bulat abu-abu
                shape: BoxShape.circle,
              ),
              child: IconButton(
                // 💡 UBAH DI SINI: Ikon hati diganti jadi keranjang
                icon: const Icon(Icons.shopping_cart_outlined,
                    size: 20, color: Colors.black87),
                onPressed: () {
                  // TODO: Tambahkan navigasi ke CartScreen Anda di sini
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10), // Jarak sedikit dari AppBar

            // --- 1. SLIDER GAMBAR (DESAIN BARU) ---
            if (images.isNotEmpty)
              Column(
                children: [
                  CarouselSlider(
                    items: images.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: double.infinity,
                            // 💡 Margin besar di kiri-kanan sesuai gambar
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  24), // Melengkung lebih halus
                              color: const Color(
                                  0xFFEEF2F6), // Warna biru keabu-abuan pucat
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              url,
                              fit: BoxFit
                                  .cover, // Jika gambarnya transparan, background di atas akan tembus
                              errorBuilder: (_, __, ___) {
                                return const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 320, // Dipertinggi sedikit agar proporsional
                      viewportFraction: 1.0,
                      autoPlay: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (images.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _currentImageIndex == entry.key ? 20.0 : 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _currentImageIndex == entry.key
                                ? const Color(0xFF3F51B5)
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              )
            else
              Container(
                height: 320,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey)),
              ),

            const SizedBox(height: 20),

            // --- 2. INFO PRODUK UTAMA ---
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20), // Disamakan dengan margin gambar
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
                      fontWeight: FontWeight.w900, // Dipertebal sedikit
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. SEKSI PILIH LENSA & RESEP ---
            if (isEyewear) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pilih Lensa Tambahan (Opsional)",
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
                              if (isSelected) {
                                selectedLens = null; // Batalkan pilihan
                              } else {
                                selectedLens = lens; // Pilih lensa
                              }
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
                                Radio<int?>(
                                  value: lens['id'],
                                  groupValue: selectedLens?['id'],
                                  toggleable: true,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == null) {
                                        selectedLens = null;
                                      } else {
                                        selectedLens = lens;
                                      }
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });

                    final Map<String, dynamic> payloadKeranjang = {
                      'product_id': widget.product['id'],
                      'qty': 1,
                      'lens_type_id': selectedLens?['id'],
                      'sph_right': _sphRightCtrl.text,
                      'cyl_right': _cylRightCtrl.text,
                      'sph_left': _sphLeftCtrl.text,
                      'cyl_left': _cylLeftCtrl.text,
                      'pd': _pdCtrl.text,
                      'note': _noteCtrl.text,
                    };

                    bool success =
                        await CartService.addToCart(payloadKeranjang);

                    setState(() {
                      _isLoading = false;
                    });

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Berhasil dimasukkan ke keranjang! 🛒'),
                          backgroundColor: Colors.green,
                        ),
                      );
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
