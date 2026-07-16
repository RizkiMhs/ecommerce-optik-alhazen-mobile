import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 💡 PENTING: Untuk format Rupiah
import '../config/api_config.dart';

// 💡 PENTING: Buka komentar import di bawah ini sesuai struktur folder Anda
import '../services/voucher_service.dart';
// import 'product_detail_screen.dart';
import '../screens/product_detail_screen.dart'; // 🚨 Pastikan path ini sesuai dengan struktur folder Anda

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _realProducts = [];
  List<dynamic> _realPromos = []; // 💡 Menyimpan data Promo/Voucher asli
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllNotifications();
  }

  // 💡 FUNGSI MENGAMBIL DATA PRODUK DAN PROMO SEKALIGUS
  Future<void> _fetchAllNotifications() async {
    try {
      // 1. Ambil Data Produk
      final resProducts = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/products"),
        headers: {'Accept': 'application/json'},
      );

      List<dynamic> products = [];
      if (resProducts.statusCode == 200) {
        final decodedData = jsonDecode(resProducts.body);
        products = decodedData['data'] ?? [];
      }

      // 2. Ambil Data Promo (Menggunakan VoucherService Anda)
      // 🚨 Buka komentar kode di bawah ini jika VoucherService sudah di-import

      final promos = await VoucherService.getAvailableVouchers();

      // 🚨 Hapus variabel promos dummy di bawah ini jika kode di atas sudah diaktifkan
      // final List<dynamic> promos = [];

      if (mounted) {
        setState(() {
          _realProducts =
              products.reversed.take(3).toList(); // Ambil 3 produk terbaru
          _realPromos = promos; // Ambil semua promo aktif
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Notifikasi",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
          : RefreshIndicator(
              color: const Color(0xFF3F51B5),
              onRefresh: _fetchAllNotifications,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ==========================================
                  // --- 1. PROMO DARI DATABASE (VOUCHER) ---
                  // ==========================================
                  const Text(
                    "Info Promo & Voucher",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  if (_realPromos.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Center(
                        child: Text("Belum ada promo aktif saat ini.",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),

                  // 💡 Looping Data Promo (Logic copy-paste dari Voucher Sheet Anda)
                  ..._realPromos.map((v) {
                    final minBelanja =
                        double.parse(v['min_purchase'].toString());
                    final formattedMinBelanja = NumberFormat.currency(
                            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                        .format(minBelanja);

                    final String discountType = v['discount_type'];
                    final double discountValue =
                        double.parse(v['discount_value'].toString());

                    String discountText = "";
                    if (discountType == 'percent') {
                      discountText = "Diskon ${discountValue.toInt()}%";
                    } else {
                      final formattedDiscount = NumberFormat.currency(
                              locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                          .format(discountValue);
                      discountText = "Potongan $formattedDiscount";
                    }

                    return _buildNotifCard(
                      icon: Icons.local_offer_rounded,
                      iconColor: Colors.orange,
                      title: "Gunakan Kode: ${v['code']} 🎉",
                      desc:
                          "Dapatkan $discountText khusus untuk kamu! Berlaku untuk minimal belanja $formattedMinBelanja.",
                      time: "Promo Aktif",
                      isUnread: true, // Sengaja true agar warnanya menonjol
                      onTap: () {
                        // Aksi opsional: Misalnya munculin notif kode disalin
                        // Clipboard.setData(ClipboardData(text: v['code']));
                        // ScaffoldMessenger.of(context).showSnackBar(...);
                      },
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // ==========================================
                  // --- 2. PRODUK BARU DARI DATABASE ---
                  // ==========================================
                  const Text(
                    "Produk Baru Rilis",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  if (_realProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Center(
                        child: Text("Belum ada produk baru.",
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ),

                  ..._realProducts.map((product) {
                    return _buildNotifCard(
                      icon: Icons.new_releases_rounded,
                      iconColor: Colors.green,
                      title: "Baru: ${product['name'] ?? 'Kacamata'}",
                      desc: product['description'] ??
                          'Koleksi terbaru kami telah hadir, cek sekarang!',
                      time: "Rilis Terbaru",
                      isUnread: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  // Widget Helper
  Widget _buildNotifCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required String time,
    required bool isUnread,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread
            ? Colors.orange.shade50
            : Colors
                .white, // Khusus promo warnanya agak orange jika belum dibaca
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isUnread ? Colors.orange.shade200 : Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                          height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isUnread)
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 8),
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
