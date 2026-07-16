import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 IMPORT TAMBAHAN UNTUK WISHLIST

// 💡 UBAH: Menjadi StatefulWidget agar ikon hati bisa berubah warna
class ProductCard extends StatefulWidget {
  final Map product;
  final VoidCallback onTap;

  const ProductCard({Key? key, required this.product, required this.onTap})
      : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // Fungsi format Rupiah
  String formatRupiah(dynamic amount) {
    double parsedAmount = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(parsedAmount);
  }

  // =======================================================
  // 🚨 AMUNISI RAHASIA: LOGIKA WISHLIST (FAVORIT) LOKAL
  // Jika dosen minta, hapus tanda /* di bawah ini dan */ di akhirnya
  // =======================================================
  
  /*
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('wishlist') ?? [];
    
    final productId = widget.product['id'].toString();
    if (mounted) {
      setState(() {
        _isFavorite = favorites.contains(productId);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('wishlist') ?? [];
    final productId = widget.product['id'].toString();

    setState(() {
      if (_isFavorite) {
        favorites.remove(productId);
        _isFavorite = false;
      } else {
        favorites.add(productId);
        _isFavorite = true;
      }
    });

    await prefs.setStringList('wishlist', favorites);
  }
  */
  
  // =======================================================

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product['image_url'];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // --- BAGIAN GAMBAR ---
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),

            // --- BAGIAN DETAIL TEKS ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // =======================================================
                      // 🚨 AMUNISI RAHASIA: TOMBOL ICON WISHLIST DI KARTU
                      // Hapus tanda /* dan */ jika dosen memintanya
                      // =======================================================
                      
                      /*
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite ? Colors.pink : Colors.grey[400],
                            size: 22,
                          ),
                        ),
                      ),
                      */
                      
                      // =======================================================
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product['description'] ?? 'No description available',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatRupiah(widget.product['base_price']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3F51B5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_basket_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}