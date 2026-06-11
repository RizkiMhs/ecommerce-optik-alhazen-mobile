import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import 'dart:io'; // 💡 Tambahkan ini untuk handle File
import 'package:image_picker/image_picker.dart'; // 💡 Tambahkan package ini

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
  final TextEditingController _axisRightCtrl =
      TextEditingController(); // 💡 AXIS KANAN

  final TextEditingController _sphLeftCtrl = TextEditingController();
  final TextEditingController _cylLeftCtrl = TextEditingController();
  final TextEditingController _axisLeftCtrl =
      TextEditingController(); // 💡 AXIS KIRI

  final TextEditingController _noteCtrl = TextEditingController();

  // STATE UNTUK LOADING TOMBOL KERANJANG
  bool _isLoading = false;

  @override
  void dispose() {
    _sphRightCtrl.dispose();
    _cylRightCtrl.dispose();
    _axisRightCtrl.dispose();

    _sphLeftCtrl.dispose();
    _cylLeftCtrl.dispose();
    _axisLeftCtrl.dispose();

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

  // 💡 STATE BARU UNTUK FOTO RESEP
  File? _prescriptionImage;
  final ImagePicker _picker = ImagePicker();

  // 💡 FUNGSI UNTUK MEMILIH GAMBAR
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Kompres agar tidak terlalu berat saat upload
      );

      if (pickedFile != null) {
        setState(() {
          _prescriptionImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  // 💡 UI: WIDGET UNTUK AREA PICKER GAMBAR
  Widget _buildImagePickerArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Atau Upload Foto Kartu Resep",
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        if (_prescriptionImage != null)
          // Tampilan jika gambar sudah dipilih
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_prescriptionImage!, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _prescriptionImage = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          )
        else
          // Tampilan tombol upload jika belum ada gambar
          Row(
            children: [
              Expanded(
                child: _buildImageSourceTile(
                  icon: Icons.camera_alt_rounded,
                  label: "Kamera",
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImageSourceTile(
                  icon: Icons.photo_library_rounded,
                  label: "Galeri",
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildImageSourceTile(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 4),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 💡 FUNGSI HELPER: Membuat kotak input resep yang modern & ramah keyboard
  Widget _buildResepField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      // 💡 PENTING: Memaksa keyboard angka + simbol minus/plus muncul di HP
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: "0.00",
        hintStyle:
            TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
        ),
      ),
    );
  }

  // 💡 FUNGSI HELPER: Menampilkan Pop-up Panduan Resep Kacamata
  void _showPrescriptionGuide() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.help_outline_rounded, color: Color(0xFF3F51B5)),
                  SizedBox(width: 8),
                  Text("Panduan Resep",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildGuideItem("SPH (Sphere / Sferis)",
                        "Kekuatan lensa utama. Isi dengan angka minus (-) untuk rabun jauh, atau plus (+) untuk rabun dekat.\nContoh: -1.50 atau +2.00"),
                    _buildGuideItem("CYL (Cylinder / Silinder)",
                        "Kekuatan lensa untuk mengoreksi mata silinder. Biasanya ditulis dengan angka minus.\nContoh: -0.50"),
                    _buildGuideItem("AXIS (Aksis / Derajat)",
                        "Menunjukkan derajat kemiringan silinder (berkisar antara 1 hingga 180). Kolom ini WAJIB diisi jika Anda memiliki nilai CYL."),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Colors.orange.shade800, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                "Kosongkan seluruh form resep ini jika Anda memiliki mata normal (Plano) atau hanya ingin membeli bingkainya saja.",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade900,
                                    height: 1.4)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Mengerti",
                      style: TextStyle(
                          color: Color(0xFF3F51B5),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                )
              ],
            ));
  }

  // Widget pembantu untuk membungkus teks penjelasan panduan
  Widget _buildGuideItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
        ],
      ),
    );
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

      // --- APP BAR ---
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
              color: Colors.grey.shade100,
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
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    size: 20, color: Colors.black87),
                onPressed: () {
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
            const SizedBox(height: 10),

            // --- 1. SLIDER GAMBAR ---
            if (images.isNotEmpty)
              Column(
                children: [
                  CarouselSlider(
                    items: images.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: const Color(0xFFEEF2F6),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
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
                      height: 320,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Produk
                      Expanded(
                        child: Text(
                          widget.product['name'] ??
                              'Nama Produk Tidak Tersedia',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Badge Stok
                      Builder(builder: (context) {
                        int stock =
                            int.tryParse(widget.product['stock'].toString()) ??
                                0;

                        Color bgColor = stock > 5
                            ? Colors.green.shade50
                            : (stock > 0
                                ? Colors.orange.shade50
                                : Colors.red.shade50);
                        Color borderColor = stock > 5
                            ? Colors.green.shade200
                            : (stock > 0
                                ? Colors.orange.shade200
                                : Colors.red.shade200);
                        Color textColor = stock > 5
                            ? Colors.green.shade700
                            : (stock > 0
                                ? Colors.orange.shade700
                                : Colors.red.shade700);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                stock > 0
                                    ? Icons.inventory_2_outlined
                                    : Icons.outbox_outlined,
                                size: 14,
                                color: textColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                stock > 0 ? "Sisa $stock" : "Habis",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Harga Produk
                  Text(
                    formatRupiah(totalPrice),
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF3F51B5),
                      fontWeight: FontWeight.w900,
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
                                selectedLens = null;
                              } else {
                                selectedLens = lens;
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

              // --- SEKSI INPUT RESEP ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 💡 TOMBOL PANDUAN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Resep Kacamata",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        InkWell(
                          onTap:
                              _showPrescriptionGuide, // Memanggil fungsi panduan
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.help_outline_rounded,
                                    size: 16, color: Color(0xFF3F51B5)),
                                SizedBox(width: 4),
                                Text("Panduan",
                                    style: TextStyle(
                                        color: Color(0xFF3F51B5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // --- MATA KANAN (R) ---
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text("R",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF3F51B5))),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      _buildResepField("SPH", _sphRightCtrl)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      _buildResepField("CYL", _cylRightCtrl)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      _buildResepField("AXIS", _axisRightCtrl)),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                                color: Colors.grey.shade200, thickness: 1),
                          ),

                          // --- MATA KIRI (L) ---
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 45,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text("L",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF3F51B5))),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildResepField("SPH", _sphLeftCtrl)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildResepField("CYL", _cylLeftCtrl)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child:
                                      _buildResepField("AXIS", _axisLeftCtrl)),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // --- CATATAN TAMBAHAN ---
                          TextField(
                            controller: _noteCtrl,
                            decoration: InputDecoration(
                              labelText: "Catatan Tambahan (Bila ada)",
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13),
                              prefixIcon: Icon(Icons.edit_note_rounded,
                                  color: Colors.grey.shade400),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFF3F51B5), width: 1.5),
                              ),
                            ),
                          ),
                          _buildImagePickerArea(),
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

                    // 💡 PAYLOAD: PD sudah dihapus, AXIS ditambahkan
                    final Map<String, dynamic> payloadKeranjang = {
                      'product_id': widget.product['id'],
                      'qty': 1,
                      'lens_type_id': selectedLens?['id'],
                      'sph_right': _sphRightCtrl.text,
                      'cyl_right': _cylRightCtrl.text,
                      'axis_right': _axisRightCtrl.text,
                      'sph_left': _sphLeftCtrl.text,
                      'cyl_left': _cylLeftCtrl.text,
                      'axis_left': _axisLeftCtrl.text,
                      'note': _noteCtrl.text,
                    };

                    // 💡 Kirim payload beserta file gambar
                    bool success = await CartService.addToCart(payloadKeranjang,
                        imageFile: _prescriptionImage // Pass filenya di sini
                        );
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
