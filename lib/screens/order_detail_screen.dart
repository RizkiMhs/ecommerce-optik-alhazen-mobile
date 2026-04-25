import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/alhazen_appbar.dart';
import 'payment_screen.dart'; // 💡 IMPORT BARU: Untuk navigasi ke Midtrans
import 'tracking_screen.dart'; // 💡 IMPORT BARU: Untuk halaman pelacakan

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  String formatRupiah(dynamic amount) {
    double parsedAmount = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(parsedAmount);
  }

  // Fungsi memecah data resep mata
  Widget _buildPrescriptionDetail(String? prescriptionJson) {
    if (prescriptionJson == null || prescriptionJson.isEmpty)
      return const SizedBox.shrink();

    try {
      final data = jsonDecode(prescriptionJson);
      if (data['sph_right'].toString().isEmpty &&
          data['sph_left'].toString().isEmpty &&
          data['pd'].toString().isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Catatan Resep Lensa:",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5))),
            const SizedBox(height: 4),
            if (data['sph_right'].toString().isNotEmpty ||
                data['cyl_right'].toString().isNotEmpty)
              Text(
                  "Kanan (R): SPH ${data['sph_right'] ?? '-'} | CYL ${data['cyl_right'] ?? '-'}",
                  style: const TextStyle(fontSize: 12)),
            if (data['sph_left'].toString().isNotEmpty ||
                data['cyl_left'].toString().isNotEmpty)
              Text(
                  "Kiri (L)  : SPH ${data['sph_left'] ?? '-'} | CYL ${data['cyl_left'] ?? '-'}",
                  style: const TextStyle(fontSize: 12)),
            // if (data['pd'].toString().isNotEmpty)
            //   Text("PD        : ${data['pd']}",
            //       style: const TextStyle(fontSize: 12)),
            if (data['note'].toString().isNotEmpty)
              Text("Catatan   : ${data['note'] ?? '-'}",
                  style: const TextStyle(
                      fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    } catch (e) {
      print("Error decode prescription: $e");
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = order['order_items'] as List<dynamic>? ?? [];

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

                  // Munculkan No Resi Jika Ada
                  // Munculkan No Resi Jika Ada
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

                    // 💡 KODE BARU: TOMBOL LACAK PESANAN
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
                          _buildPrescriptionDetail(item['prescription_data']),
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
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider()),
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
          ],
        ),
      ),

      // 💡 FITUR BARU: Tombol Bayar Sekarang menempel di bawah (Hanya jika unpaid)
      bottomNavigationBar: (order['status'] == 'unpaid' &&
              order['payment_token'] != null)
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
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentScreen(snapToken: order['payment_token']),
                        ),
                      ).then((_) {
                        // Kembali ke layar OrderScreen agar daftar list-nya bisa di-refresh
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
              ),
            )
          : null, // Jika status bukan unpaid, tombol tidak akan muncul
    );
  }
}
