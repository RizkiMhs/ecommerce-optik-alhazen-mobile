import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../services/order_service.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;
  final String trackingNumber;
  final String courierName;

  const TrackingScreen({
    super.key,
    required this.orderId,
    required this.trackingNumber,
    required this.courierName,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  List<dynamic> trackingHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrackingData();
  }

  void _fetchTrackingData() async {
    final history = await OrderService.trackOrder(widget.orderId);
    if (mounted) {
      setState(() {
        // Biteship kadang mengurutkan dari terlama ke terbaru. 
        // Kita .reversed agar status terbaru selalu ada di paling atas!
        trackingHistory = history;
        isLoading = false;
      });
    }
  }

  // Fungsi untuk membersihkan format tanggal dari Biteship
  String formatDate(String rawDate) {
    try {
      // Contoh input: 2026-04-25T14:00:00+07:00
      DateTime parsed = DateTime.parse(rawDate).toLocal();
      return "${parsed.day}-${parsed.month}-${parsed.year} ${parsed.hour}:${parsed.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lacak Pesanan", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info Resi
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: Color(0xFF3F51B5), size: 30),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.courierName.toUpperCase(), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Resi: ${widget.trackingNumber}", 
                        style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // Timeline List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
                : trackingHistory.isEmpty
                    ? const Center(child: Text("Belum ada data perjalanan paket."))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: trackingHistory.length,
                        itemBuilder: (context, index) {
                          final item = trackingHistory[index];
                          final bool isFirst = index == 0; // Item paling atas (Terbaru)
                          final bool isLast = index == trackingHistory.length - 1;

                          return TimelineTile(
                            alignment: TimelineAlign.manual,
                            lineXY: 0.1, // Posisi garis vertikal
                            isFirst: isFirst,
                            isLast: isLast,
                            indicatorStyle: IndicatorStyle(
                              width: 20,
                              // Warna biru untuk status terbaru, abu-abu untuk yang lama
                              color: isFirst ? const Color(0xFF3F51B5) : Colors.grey[400]!,
                              iconStyle: isFirst
                                  ? IconStyle(iconData: Icons.check, color: Colors.white, fontSize: 14)
                                  : null,
                            ),
                            beforeLineStyle: LineStyle(
                              color: isFirst ? const Color(0xFF3F51B5) : Colors.grey[300]!,
                              thickness: 2,
                            ),
                            afterLineStyle: LineStyle(
                              color: Colors.grey[300]!,
                              thickness: 2,
                            ),
                            endChild: Container(
                              padding: const EdgeInsets.all(16),
                              constraints: const BoxConstraints(minHeight: 80),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['note'] ?? 'Status diupdate',
                                    style: TextStyle(
                                      fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
                                      color: isFirst ? Colors.black87 : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    formatDate(item['updated_at'] ?? ''),
                                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}