import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({Key? key}) : super(key: key);

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> promoData = [
    {
      "tag": "PROMO SPESIAL",
      "title": "Diskon Kacamata\nHingga 50%",
      // 💡 PERBAIKAN: Pastikan path ini SAMA PERSIS dengan letak gambar Anda
      "image": "assets/images/banner1.jpg",
      "tagColor": Colors.orange,
    },
    {
      "tag": "GRATIS ONGKIR",
      "title": "Bebas Biaya Kirim\nKe Seluruh Indonesia",
      // 💡 PERBAIKAN PATH GAMBAR
      "image": "assets/images/banner2.jpg",
      "tagColor": Colors.redAccent,
    },
    {
      "tag": "NEW ARRIVAL",
      "title": "Koleksi Terbaru\nTampil Lebih Gaya",
      // 💡 PERBAIKAN PATH GAMBAR
      "image": "assets/images/banner3.jpg",
      "tagColor": Colors.amber,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: promoData.map((promo) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade200,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // --- 1. GAMBAR BACKGROUND ---
                      // 💡 PERBAIKAN: Memberikan pengaman (fallback) jika gambar gagal dimuat
                      Image.asset(
                        promo["image"] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                          );
                        },
                      ),

                      // --- 2. OVERLAY GELAP ---
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color.fromARGB(255, 0, 101, 184)
                                  .withOpacity(0.8),
                              const Color.fromARGB(255, 173, 216, 230)
                                  .withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),

                      // --- 3. TEKS PROMO ---
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                // 💡 PERBAIKAN: Pengaman warna
                                color: promo["tagColor"] ?? Colors.grey,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                // 💡 PERBAIKAN: Pengaman Null String
                                promo["tag"] ?? 'Promo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              // 💡 PERBAIKAN: Pengaman Null String
                              promo["title"] ?? 'Penawaran Menarik',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // Indikator Titik-titik (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: promoData.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentIndex == entry.key ? 20.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _currentIndex == entry.key
                    ? const Color(0xFF3F51B5)
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
