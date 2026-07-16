import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:optik_alhazen_app/services/order_service.dart';
import '../widgets/alhazen_appbar.dart';
import 'payment_screen.dart'; // Untuk navigasi ke Midtrans
import 'tracking_screen.dart'; // Untuk halaman pelacakan
import '../config/api_config.dart'; // Untuk mendapatkan base URL API

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  String formatRupiah(dynamic amount) {
    double parsedAmount = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(parsedAmount);
  }

  void _showPrescriptionImageDialog(BuildContext context, String imagePath) {
    final String serverUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    final String fullUrl = "$serverUrl/storage/$imagePath";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 1,
              maxScale: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.white,
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF3F51B5))),
                      );
                    },
                    errorBuilder: (ctx, err, stack) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade100,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_rounded,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Gagal memuat foto resep",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionDetail(
      BuildContext context, Map<String, dynamic> item) {
    final String? prescriptionJson = item['prescription_data'];
    Map<String, dynamic> data = {};

    if (prescriptionJson != null && prescriptionJson.isNotEmpty) {
      try {
        data = jsonDecode(prescriptionJson);
      } catch (e) {
        print("Error decode prescription JSON: $e");
      }
    }

    final String imagePath =
        (item['prescription_image'] ?? data['prescription_image'] ?? '')
            .toString();

    if ((data['sph_right'].toString().isEmpty || data['sph_right'] == null) &&
        (data['sph_left'].toString().isEmpty || data['sph_left'] == null) &&
        (data['pd'].toString().isEmpty || data['pd'] == null) &&
        imagePath.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_outlined,
                  size: 14, color: Color(0xFF3F51B5)),
              SizedBox(width: 4),
              Text("Catatan Resep Lensa:",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5))),
            ],
          ),
          const SizedBox(height: 6),
          if (data['sph_right'].toString().isNotEmpty &&
              data['sph_right'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                  "Kanan (R): SPH ${data['sph_right'] ?? '-'} | CYL ${data['cyl_right'] ?? '-'} | AXIS ${data['axis_right'] ?? '-'}",
                  style: const TextStyle(
                    fontSize: 12,
                  )),
            ),
          if (data['sph_left'].toString().isNotEmpty &&
              data['sph_left'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                  "Kiri (L)  : SPH ${data['sph_left'] ?? '-'} | CYL ${data['cyl_left'] ?? '-'} | AXIS ${data['axis_left'] ?? '-'}",
                  style: const TextStyle(
                    fontSize: 12,
                  )),
            ),
          if (data['pd'].toString().isNotEmpty && data['pd'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text("PD        : ${data['pd']}",
                  style: const TextStyle(fontSize: 12)),
            ),
          if (data['note'].toString().isNotEmpty && data['note'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text("Catatan   : ${data['note'] ?? '-'}",
                  style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54)),
            ),
          if (imagePath.isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _showPrescriptionImageDialog(context, imagePath),
              borderRadius: BorderRadius.circular(8),
              child: Ink(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF3F51B5).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_search_rounded,
                        size: 16, color: Color(0xFF3F51B5)),
                    SizedBox(width: 6),
                    Text(
                      "Lihat Foto Resep",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3F51B5),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Pesanan'),
          content: const Text(
              'Apakah Anda yakin ingin membatalkan pesanan ini? Aksi ini tidak dapat diurungkan.'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          actions: [
            TextButton(
              child: const Text('Tutup', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ya, Batalkan',
                  style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  final bool success =
                      await OrderService.cancelOrder(order['id'].toString());

                  Navigator.of(context).pop();

                  if (success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pesanan berhasil dibatalkan.'),
                            backgroundColor: Colors.green),
                      );
                      Navigator.pop(context);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gagal membatalkan pesanan.'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Terjadi kesalahan: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 💡 FUNGSI MEMUNCULKAN POP-UP ULASAN
  void _showReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Variabel lokal untuk menyimpan state bintang dan teks
        int _rating = 5;
        TextEditingController _reviewController = TextEditingController();

        // Menggunakan StatefulBuilder agar bintang bisa diklik & berubah warna di dalam pop-up
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    20, // Agar tidak tertutup keyboard
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Menyesuaikan tinggi otomatis
                children: [
                  const Text(
                    "Bagaimana Pesanan Anda? 📦",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bantu kami dan pembeli lain dengan memberikan ulasan untuk produk ini.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // --- BINTANG RATING INTERAKTIF ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: 45,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          index < _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setModalState(() {
                            _rating = index + 1; // Ubah jumlah bintang
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _rating == 5
                        ? "Sangat Bagus!"
                        : _rating == 4
                            ? "Bagus"
                            : _rating == 3
                                ? "Lumayan"
                                : _rating == 2
                                    ? "Kurang"
                                    : "Sangat Buruk",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700),
                  ),
                  const SizedBox(height: 24),

                  // --- KOLOM KOMENTAR ---
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          "Tulis pengalamanmu menggunakan kacamata ini...",
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3F51B5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- TOMBOL KIRIM ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Tutup Bottom Sheet
                        Navigator.pop(context);

                        // Tampilkan Notifikasi Sukses
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Terima kasih! Ulasan Anda berhasil dikirim. ❤️"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        "Kirim Ulasan",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = order['order_items'] as List<dynamic>? ?? [];

    // 💡 MENYIAPKAN DATA ALAMAT (Jika disimpan dalam bentuk String JSON di backend)
    Map<String, dynamic> addressData = {};
    if (order['address_snapshot'] != null) {
      if (order['address_snapshot'] is String) {
        try {
          addressData = jsonDecode(order['address_snapshot']);
        } catch (e) {
          print("Error decode address: $e");
        }
      } else if (order['address_snapshot'] is Map) {
        addressData = order['address_snapshot'];
      }
    }

    // 💡 MENYIAPKAN DATA DISKON
    final double discountAmount =
        double.tryParse(order['discount_amount']?.toString() ?? '0') ?? 0;
    final String? voucherCode = order['voucher_code'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AlhazenAppBar(title: "Detail Pesanan", showCart: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. KOTAK INFO STATUS & RESI ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nomor Pesanan",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(order['order_number'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const Divider(height: 24),
                  Text("Tanggal Pemesanan",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(order['created_at'].toString().substring(0, 10),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  if (order['tracking_number'] != null &&
                      order['tracking_number'].toString().isNotEmpty) ...[
                    const Divider(height: 24),
                    Text("Nomor Resi Pengiriman",
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(order['tracking_number'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF3F51B5))),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackingScreen(
                                orderId: order['id'].toString(),
                                trackingNumber: order['tracking_number'],
                                courierName: order['courier'] ?? 'Kurir',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_on_outlined, size: 18),
                        label: const Text("Lacak Perjalanan Paket"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3F51B5),
                          side: const BorderSide(color: Color(0xFF3F51B5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 💡 --- KOTAK ALAMAT PENGIRIMAN (FITUR BARU) ---
            if (addressData.isNotEmpty) ...[
              const Text("Alamat Pengiriman",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFF3F51B5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "${addressData['name'] ?? '-'} (${addressData['phone'] ?? '-'})",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(addressData['address'] ?? '-',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // --- 2. KOTAK DAFTAR BARANG ---
            const Text("Daftar Barang",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.shopping_bag_rounded,
                          color: Color(0xFF3F51B5)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['product']['name'] ?? 'Produk',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          if (item['lens_type'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 4),
                              child: Text(
                                  "+ Lensa ${item['lens_type']['lens_name']}",
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13)),
                            ),
                          Text(
                              "${item['qty']} x ${formatRupiah(item['price_at_purchase'])}",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13)),
                          _buildPrescriptionDetail(context, item),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),

            // --- 3. KOTAK RINGKASAN PEMBAYARAN ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ringkasan Pembayaran",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  // Ongkos Kirim
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Ongkos Kirim",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13)),
                      Text(formatRupiah(order['shipping_cost'] ?? 0),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),

                  // 💡 DISKON VOUCHER DITAMPILKAN DI SINI JIKA ADA
                  if (discountAmount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            voucherCode != null
                                ? "Diskon ($voucherCode)"
                                : "Diskon Voucher",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                        Text("- ${formatRupiah(discountAmount)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.green)),
                      ],
                    ),
                  ],

                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider()),

                  // Total Belanja
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Belanja",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(formatRupiah(order['total_amount']),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF3F51B5))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // if (order['status'] == 'completed') ...[
            //     const SizedBox(height: 20),
            //     SizedBox(
            //       width: double.infinity,
            //       height: 48,
            //       child: OutlinedButton.icon(
            //         style: OutlinedButton.styleFrom(
            //           side: const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         icon: const Icon(Icons.star_rate_rounded, color: Colors.amber),
            //         label: const Text(
            //           "Beri Ulasan Produk",
            //           style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
            //         ),
            //         onPressed: () {
            //           _showReviewSheet(context); // Panggil fungsi pop-up ulasan
            //         },
            //       ),
            //     ),
            //   ],
          ],
        ),
      ),
      bottomNavigationBar:
          (order['status'] == 'unpaid' && order['payment_token'] != null)
              ? Container(
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
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                      snapToken: order['payment_token']),
                                ),
                              ).then((_) {
                                Navigator.pop(context);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text("Bayar Sekarang",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              _showCancelConfirmationDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Batalkan Pesanan",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
    );
  }
}
