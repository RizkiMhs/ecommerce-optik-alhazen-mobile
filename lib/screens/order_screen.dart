

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import 'payment_screen.dart'; // Untuk tombol Lanjutkan Pembayaran
import 'order_detail_screen.dart'; // 💡 Tambahkan ini

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = true;
  List<dynamic> allOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    final data = await OrderService.fetchOrders();
    setState(() {
      allOrders = data;
      isLoading = false;
    });
  }

  // Fungsi untuk memformat mata uang Rupiah
  String formatRupiah(dynamic amount) {
    double parsedAmount = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(parsedAmount);
  }

  // Widget Placeholder Gambar
  Widget _buildPlaceholder() {
    return Container(
      width: 60, // Sedikit diperbesar agar lebih proporsional
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          const Icon(Icons.image_outlined, size: 28, color: Color(0xFF3F51B5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(
            0xFFF8F9FA), // Warna background abu-abu sangat muda (modern)
        appBar: AppBar(
          title: const Text("Pesanan Saya",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0.5, // Shadow sangat tipis untuk AppBar
          shadowColor: Colors.black26,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Color(0xFF3F51B5),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF3F51B5),
            indicatorWeight: 3, // Garis indikator sedikit ditebalkan
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle:
                TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: [
              Tab(text: "Belum Bayar"),
              Tab(text: "Diproses"),
              Tab(text: "Dikirim"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
            : TabBarView(
                children: [
                  // 💡 UPDATE: Kita kirimkan array (List) status
                  _buildOrderList(['unpaid']),                  // Tab 1
                  _buildOrderList(['paid', 'processing']),      // Tab 2
                  _buildOrderList(['shipping', 'completed']),   // Tab 3
                ],
              ),
      ),
    );
  }

  // 💡 UI BARU: Empty State yang lebih cantik
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada pesanan",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text("Daftar pesanan Anda akan tampil di sini.",
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }

  // 💡 UPDATE PARAMETER: Sekarang menerima List<String> bukan cuma String
  Widget _buildOrderList(List<String> statusFilters) {
    final filteredOrders = allOrders.where((order) {
      String dbStatus = order['status'];
      
      // 1. Cek apakah status dari database ada di dalam daftar filter Tab ini
      bool isMatch = statusFilters.contains(dbStatus);

      // 2. Logika 24 Jam khusus untuk unpaid
      if (dbStatus == 'unpaid' && isMatch) {
        try {
          DateTime createdAt = DateTime.parse(order['created_at']);
          DateTime expiredAt = createdAt.add(const Duration(hours: 12));
          DateTime now = DateTime.now();
          if (now.isAfter(expiredAt)) return false; // Sembunyikan jika expired
        } catch (e) {
          print("Error parsing date: $e");
        }
      }

      return isMatch;
    }).toList();

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF3F51B5),
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          final items = order['order_items'] as List<dynamic>;
          final firstItem = items.isNotEmpty ? items[0] : null;

          // 💡 UPDATE: Warna Badge disesuaikan dengan ENUM Database Anda
          Color badgeColor;
          Color badgeTextColor;
          String badgeText;
          String currentStatus = order['status'];

          switch (currentStatus) {
            case 'unpaid':
              badgeColor = Colors.red.shade50;
              badgeTextColor = Colors.red.shade700;
              badgeText = "Belum Bayar";
              break;
            case 'paid':
              badgeColor = Colors.orange.shade50;
              badgeTextColor = Colors.orange.shade700;
              badgeText = "Menunggu Konfirmasi"; // Baru bayar, admin belum proses
              break;
            case 'processing':
              badgeColor = Colors.blue.shade50;
              badgeTextColor = Colors.blue.shade700;
              badgeText = "Sedang Dikerjakan"; // Lensa sedang dirakit
              break;
            case 'shipping':
              badgeColor = Colors.purple.shade50;
              badgeTextColor = Colors.purple.shade700;
              badgeText = "Dalam Pengiriman";
              break;
            case 'completed':
              badgeColor = Colors.green.shade50;
              badgeTextColor = Colors.green.shade700;
              badgeText = "Pesanan Selesai";
              break;
            default:
              badgeColor = Colors.grey.shade100;
              badgeTextColor = Colors.grey.shade700;
              badgeText = currentStatus;
          }

          return GestureDetector(
            onTap: () {
              // Pindah ke halaman detail sambil membawa data 'order'
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER CARD ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(order['created_at'].toString().substring(0, 10),
                                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                                color: badgeTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
            
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                    ),
            
                    // --- BODY CARD (PRODUK) ---
                    if (firstItem != null && firstItem['product'] != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: (firstItem['product']['image_url'] != null &&
                                    firstItem['product']['image_url'].toString().isNotEmpty)
                                ? Image.network(
                                    firstItem['product']['image_url'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return _buildPlaceholder();
                                    },
                                  )
                                : _buildPlaceholder(),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(firstItem['product']['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                if (items.length > 1)
                                  Text("+ ${items.length - 1} produk lainnya",
                                      style: TextStyle(
                                          color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
            
                    const SizedBox(height: 16),
            
                    // --- FOOTER CARD (TOTAL & TOMBOL) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Belanja",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(formatRupiah(order['total_amount']),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        
                        // 💡 Tombol Bayar HANYA muncul jika status benar-benar 'unpaid'
                        if (currentStatus == "unpaid" && order['payment_token'] != null)
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PaymentScreen(
                                          snapToken: order['payment_token'])),
                                ).then((_) => _loadOrders());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F51B5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Bayar Sekarang",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
