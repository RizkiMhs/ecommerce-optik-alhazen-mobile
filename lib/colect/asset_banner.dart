// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert'; // 💡 PENTING: Untuk decode JSON API
// import 'package:http/http.dart' as http; // 💡 PENTING: Untuk request API Produk
// // 💡 Sesuaikan import di bawah ini dengan lokasi file Anda
// import '../config/api_config.dart';
// import '../services/voucher_service.dart';
// import '../screens/product_detail_screen.dart';

// class PromoCarousel extends StatefulWidget {
//   const PromoCarousel({Key? key}) : super(key: key);

//   @override
//   State<PromoCarousel> createState() => _PromoCarouselState();
// }

// class _PromoCarouselState extends State<PromoCarousel> {
//   int _currentIndex = 0;

//   final List<Map<String, dynamic>> promoData = [
//     {
//       "tag": "HEMAT SETIAP HARI",
//       "title": "Klaim Voucher\n& Promo Eksklusif",
//       "image": "assets/images/banner1.jpg",
//       "tagColor": Colors.orange,
//     },
//     {
//       "tag": "PRODUK PILIHAN",
//       "title": "Kualitas Terbaik\nUntuk Kebutuhan Anda",
//       "image": "assets/images/banner2.jpg",
//       "tagColor": Colors.redAccent,
//     },
//     {
//       "tag": "NEW ARRIVAL",
//       "title": "Koleksi Terbaru\nTampil Lebih Gaya",
//       "image": "assets/images/banner3.jpg",
//       "tagColor": Colors.amber,
//     },
//   ];

//   // =========================================================
//   // 1. FUNGSI MENAMPILKAN SHEET VOUCHER (BANNER 1)
//   // =========================================================
//   void _showVouchersSheet() {
//     showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (context) {
//           return Container(
//             height: MediaQuery.of(context).size.height * 0.65,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 12, bottom: 8),
//                     width: 50,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: Text("Promo & Voucher Aktif",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ),
//                 const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
//                 Expanded(
//                   child: FutureBuilder<List<dynamic>>(
//                       // 🚨 Pastikan VoucherService aktif
//                       future: VoucherService.getAvailableVouchers(),
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator(
//                                   color: Color(0xFF3F51B5)));
//                         } else if (!snapshot.hasData ||
//                             snapshot.data!.isEmpty) {
//                           return Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.local_offer_outlined,
//                                     size: 60, color: Colors.grey[300]),
//                                 const SizedBox(height: 16),
//                                 Text("Belum ada promo saat ini.",
//                                     style: TextStyle(
//                                         color: Colors.grey[500], fontSize: 16)),
//                               ],
//                             ),
//                           );
//                         }

//                         return ListView.builder(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 10),
//                           itemCount: snapshot.data!.length,
//                           itemBuilder: (context, index) {
//                             final v = snapshot.data![index];
//                             final minBelanja =
//                                 double.parse(v['min_purchase'].toString());
//                             final formattedMinBelanja = NumberFormat.currency(
//                                     locale: 'id_ID',
//                                     symbol: 'Rp ',
//                                     decimalDigits: 0)
//                                 .format(minBelanja);

//                             final String discountType = v['discount_type'];
//                             final double discountValue =
//                                 double.parse(v['discount_value'].toString());

//                             String discountText = "";
//                             if (discountType == 'percent') {
//                               discountText = "Diskon ${discountValue.toInt()}%";
//                             } else {
//                               final formattedDiscount = NumberFormat.currency(
//                                       locale: 'id_ID',
//                                       symbol: 'Rp ',
//                                       decimalDigits: 0)
//                                   .format(discountValue);
//                               discountText = "Potongan $formattedDiscount";
//                             }

//                             return Card(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               shape: RoundedRectangleBorder(
//                                   side: BorderSide(color: Colors.red.shade200),
//                                   borderRadius: BorderRadius.circular(12)),
//                               color: Colors.red.shade50,
//                               elevation: 0,
//                               child: ListTile(
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 8),
//                                 leading: const Icon(Icons.local_offer,
//                                     color: Colors.redAccent, size: 28),
//                                 title: Text(v['code'],
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w900,
//                                         fontSize: 16,
//                                         color: Colors.redAccent,
//                                         letterSpacing: 1)),
//                                 subtitle: Padding(
//                                   padding: const EdgeInsets.only(top: 6.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(discountText,
//                                           style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                               color: Colors.black87,
//                                               fontSize: 13)),
//                                       const SizedBox(height: 2),
//                                       Text("Min. belanja $formattedMinBelanja",
//                                           style: TextStyle(
//                                               color: Colors.grey.shade700,
//                                               fontSize: 12)),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       }),
//                 ),
//               ],
//             ),
//           );
//         });
//   }

//   // =========================================================
//   // 2. FUNGSI BARU: MENAMPILKAN SHEET PRODUK (BANNER 2 & 3)
//   // =========================================================
//   void _showProductsSheet(String title, bool isNewArrival) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           height:
//               MediaQuery.of(context).size.height * 0.75, // Dibuat lebih tinggi
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --- DRAG HANDLE ---
//               Center(
//                 child: Container(
//                   margin: const EdgeInsets.only(top: 12, bottom: 8),
//                   width: 50,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),

//               // --- HEADER DINAMIS ---
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 child: Text(title,
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold)),
//               ),
//               const Divider(thickness: 1, color: Color(0xFFEEEEEE)),

//               // --- LIST PRODUK DARI API ---
//               Expanded(
//                 child: FutureBuilder<http.Response>(
//                   // 🚨 Pastikan ApiConfig di-import dan endpoint /products sesuai
//                   future: http.get(Uri.parse("${ApiConfig.baseUrl}/products"),
//                       headers: {'Accept': 'application/json'}),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(
//                           child: CircularProgressIndicator(
//                               color: Color(0xFF3F51B5)));
//                     }

//                     if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
//                       return const Center(child: Text("Gagal memuat produk."));
//                     }

//                     final decodedData = jsonDecode(snapshot.data!.body);
//                     List<dynamic> products = decodedData['data'] ?? [];

//                     // 💡 LOGIKA SORTING
//                     // Jika diklik banner 3 (New Arrival), balik urutannya agar produk terbaru di atas
//                     if (isNewArrival) {
//                       products = products.reversed.toList();
//                     } else {
//                       // Jika diklik banner 2 (Produk Pilihan), acak urutannya agar terlihat berbeda
//                       products.shuffle();
//                     }

//                     // Ambil 5 data saja agar tidak terlalu berat
//                     final displayProducts = products.take(5).toList();

//                     return ListView.builder(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                       itemCount: displayProducts.length,
//                       itemBuilder: (context, index) {
//                         final product = displayProducts[index];
//                         final imageUrl = product['image_url'];

//                         // Format Harga
//                         final price =
//                             double.tryParse(product['base_price'].toString()) ??
//                                 0;
//                         final formattedPrice = NumberFormat.currency(
//                                 locale: 'id_ID',
//                                 symbol: 'Rp ',
//                                 decimalDigits: 0)
//                             .format(price);

//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             children: [
//                               // Gambar Produk
//                               Container(
//                                 width: 70,
//                                 height: 70,
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[100],
//                                     borderRadius: BorderRadius.circular(8)),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: (imageUrl != null &&
//                                           imageUrl.isNotEmpty)
//                                       ? Image.network(imageUrl,
//                                           fit: BoxFit.cover,
//                                           errorBuilder: (c, e, s) =>
//                                               const Icon(Icons.broken_image))
//                                       : const Icon(Icons.image,
//                                           color: Colors.grey),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               // Detail Produk
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(product['name'] ?? 'Kacamata',
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 14)),
//                                     const SizedBox(height: 4),
//                                     Text(formattedPrice,
//                                         style: const TextStyle(
//                                             color: Color(0xFF3F51B5),
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 13)),
//                                   ],
//                                 ),
//                               ),
//                               // Tombol Aksi (Opsional: Lihat Detail)
//                               IconButton(
//                                 icon: const Icon(
//                                     Icons.arrow_forward_ios_rounded,
//                                     size: 16,
//                                     color: Colors.grey),
//                                 onPressed: () {
//                                   // 🚨 Buka komentar ini jika ingin navigasi ke detail produk

//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             ProductDetailScreen(
//                                                 product: product)),
//                                   );
//                                 },
//                               )
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CarouselSlider(
//           options: CarouselOptions(
//             height: 160.0,
//             autoPlay: true,
//             autoPlayInterval: const Duration(seconds: 4),
//             viewportFraction: 1,
//             onPageChanged: (index, reason) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//           ),
//           // 💡 PERUBAHAN UTAMA: Menggunakan asMap().entries agar kita tahu INDEX banner yang diklik
//           items: promoData.asMap().entries.map((entry) {
//             int index = entry.key;
//             Map<String, dynamic> promo = entry.value;

//             return Builder(
//               builder: (BuildContext context) {
//                 return GestureDetector(
//                   onTap: () {
//                     // 💡 LOGIKA KLIK BERDASARKAN INDEX
//                     if (index == 0) {
//                       // Banner 1: Buka Voucher Sheet
//                       _showVouchersSheet();
//                     } else if (index == 1) {
//                       // Banner 2: Buka Sheet Produk Pilihan (Acak)
//                       _showProductsSheet("Koleksi Produk Pilihan 🔥", false);
//                     } else if (index == 2) {
//                       // Banner 3: Buka Sheet Produk Baru Rilis (Terbaru)
//                       _showProductsSheet("New Arrival - Rilis Terbaru ✨", true);
//                     }
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     margin: const EdgeInsets.symmetric(horizontal: 3),
//                     clipBehavior: Clip.hardEdge,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: Colors.grey.shade200,
//                     ),
//                     child: Stack(
//                       fit: StackFit.expand,
//                       children: [
//                         Image.asset(
//                           promo["image"] ?? '',
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               const Center(
//                                   child: Icon(Icons.broken_image,
//                                       size: 50, color: Colors.grey)),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.bottomCenter,
//                               end: Alignment.topCenter,
//                               colors: [
//                                 const Color.fromARGB(255, 0, 101, 184)
//                                     .withOpacity(0.8),
//                                 const Color.fromARGB(255, 173, 216, 230)
//                                     .withOpacity(0.1),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(20.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: promo["tagColor"] ?? Colors.grey,
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   promo["tag"] ?? 'Promo',
//                                   style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 promo["title"] ?? 'Penawaran Menarik',
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     height: 1.2),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 14),

//         // Indikator Titik-titik (Dots)
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: promoData.asMap().entries.map((entry) {
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               width: _currentIndex == entry.key ? 20.0 : 8.0,
//               height: 8.0,
//               margin: const EdgeInsets.symmetric(horizontal: 4.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: _currentIndex == entry.key
//                     ? const Color(0xFF3F51B5)
//                     : Colors.grey.shade300,
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }




// bottomSheet: Container(
//         padding: const EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom:
//                 24), // Tambah bottom padding agar aman di layar iPhone/tanpa tombol fisik
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, -5)),
//           ],
//         ),
//         child: Row(
//           children: [
//             // --- TOMBOL MASUKKAN KERANJANG ---
//             Expanded(
//               child: SizedBox(
//                 height: 48,
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFF3F51B5),
//                     side:
//                         const BorderSide(color: Color(0xFF3F51B5), width: 1.5),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: _isLoading
//                       ? null
//                       : () async {
//                           setState(() => _isLoading = true);
//                           final Map<String, dynamic> payloadKeranjang = {
//                             'product_id': widget.product['id'],
//                             'qty': 1,
//                             'lens_type_id': selectedLens?['id'],
//                             'sph_right': _sphRightCtrl.text,
//                             'cyl_right': _cylRightCtrl.text,
//                             'axis_right': _axisRightCtrl.text,
//                             'sph_left': _sphLeftCtrl.text,
//                             'cyl_left': _cylLeftCtrl.text,
//                             'axis_left': _axisLeftCtrl.text,
//                             'note': _noteCtrl.text,
//                           };

//                           bool success = await CartService.addToCart(
//                               payloadKeranjang,
//                               imageFile: _prescriptionImage);
//                           setState(() => _isLoading = false);

//                           if (success) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text(
//                                       'Berhasil dimasukkan ke keranjang! 🛒'),
//                                   backgroundColor: Colors.green),
//                             );
//                             Navigator.pop(context);
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text(
//                                       'Gagal memasukkan ke keranjang. Coba lagi.'),
//                                   backgroundColor: Colors.red),
//                             );
//                           }
//                         },
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2))
//                       : const Text("Keranjang",
//                           style: TextStyle(
//                               fontSize: 14, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ),

//             const SizedBox(width: 12), // Jarak antar tombol

//             Expanded(
//               child: SizedBox(
//                 height: 48,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3F51B5),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     elevation: 0,
//                   ),
//                   onPressed: _isLoading
//                       ? null
//                       : () async {
//                           // 1. Mulai loading
//                           setState(() => _isLoading = true);

//                           final Map<String, dynamic> payloadKeranjang = {
//                             'product_id': widget.product['id'],
//                             'qty': 1,
//                             'lens_type_id': selectedLens?['id'],
//                             'sph_right': _sphRightCtrl.text,
//                             'cyl_right': _cylRightCtrl.text,
//                             'axis_right': _axisRightCtrl.text,
//                             'sph_left': _sphLeftCtrl.text,
//                             'cyl_left': _cylLeftCtrl.text,
//                             'axis_left': _axisLeftCtrl.text,
//                             'note': _noteCtrl.text,
//                           };

//                           // 2. Masukkan ke tabel keranjang
//                           bool success = await CartService.addToCart(
//                               payloadKeranjang,
//                               imageFile: _prescriptionImage);

//                           if (success) {
//                             // 💡 SOLUSI ERROR: Ambil data keranjang terbaru dari API
//                             final updatedCart =
//                                 await CartService.getCartItems();

//                             // Matikan loading sebelum pindah halaman
//                             setState(() => _isLoading = false);

//                             // 💡 FILTER: Kita cari item di keranjang yang product_id-nya sama dengan produk ini
//                             final checkoutItems = updatedCart.where((item) {
//                               // Sesuaikan key 'product_id' atau 'product'/'id' dengan response API Keranjang Anda
//                               return item['product_id'] ==
//                                       widget.product['id'] ||
//                                   (item['product'] != null &&
//                                       item['product']['id'] ==
//                                           widget.product['id']);
//                             }).toList();

//                             // 3. Pindah ke Checkout sambil membawa parameter 'selectedItems'
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => CheckoutScreen(
//                                   selectedItems:
//                                       checkoutItems, // 👈 INI YANG MENGHILANGKAN ERROR!
//                                 ),
//                               ),
//                             );

//                             // (Opsional) Refresh icon keranjang di atas
//                             _fetchCartCount();
//                           } else {
//                             setState(() => _isLoading = false);
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text(
//                                       'Gagal memproses pesanan. Coba lagi.'),
//                                   backgroundColor: Colors.red),
//                             );
//                           }
//                         },
//                   child: const Text("Beli Sekarang",
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),