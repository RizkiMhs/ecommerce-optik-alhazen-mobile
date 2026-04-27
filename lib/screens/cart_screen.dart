import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 💡 IMPORT BARU UNTUK FORMAT HARGA
import 'package:optik_alhazen_app/config/api_config.dart';
import '../services/cart_service.dart';
import '../widgets/alhazen_appbar.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;

  Set<int> selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  void fetchCart() async {
    final data = await CartService.getCartItems();
    setState(() {
      cartItems = data;
      isLoading = false;
    });
  }

  void changeQty(int index, int delta) {
    setState(() {
      int newQty = cartItems[index]['qty'] + delta;
      if (newQty > 0) {
        cartItems[index]['qty'] = newQty;
        CartService.updateQty(cartItems[index]['id'], newQty);
      }
    });
  }

  void removeItem(int index) async {
    int id = cartItems[index]['id'];
    setState(() {
      cartItems.removeAt(index);
      selectedItemIds.remove(id);
    });
    await CartService.deleteItem(id);
  }

  void toggleSelection(int cartId) {
    setState(() {
      if (selectedItemIds.contains(cartId)) {
        selectedItemIds.remove(cartId);
      } else {
        selectedItemIds.add(cartId);
      }
    });
  }

  void toggleAll(bool? value) {
    setState(() {
      if (value == true) {
        selectedItemIds =
            cartItems.map<int>((item) => item['id'] as int).toSet();
      } else {
        selectedItemIds.clear();
      }
    });
  }

  // 💡 FUNGSI BARU: Untuk mengubah angka mentah menjadi format Rupiah rapi
  String formatRupiah(dynamic amount) {
    double parsedAmount = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(parsedAmount);
  }

  @override
  Widget build(BuildContext context) {
    double total = cartItems
        .where((item) => selectedItemIds.contains(item['id']))
        .fold(0, (sum, item) {
      double base = double.parse(item['product']['base_price'].toString());
      double lens = double.parse(
          (item['lens_type']?['additional_price'] ?? 0).toString());
      return sum + ((base + lens) * item['qty']);
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AlhazenAppBar(title: "Keranjang Belanja", showCart: false),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
          : cartItems.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];

                          double itemBasePrice = double.parse(
                              item['product']['base_price'].toString());
                          double itemLensPrice = double.parse(
                              (item['lens_type']?['additional_price'] ?? 0)
                                  .toString());
                          double itemTotalPrice = itemBasePrice + itemLensPrice;

                          return _buildCartItemCard(
                              item, itemTotalPrice, index);
                        },
                      ),
                    ),
                  ],
                ),
      bottomSheet:
          cartItems.isEmpty || isLoading ? null : _buildCheckoutBar(total),
    );
  }

  Widget buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          const Icon(Icons.image_outlined, size: 40, color: Color(0xFF3F51B5)),
    );
  }

  Widget _buildCartItemCard(dynamic item, double itemTotalPrice, int index) {
    final productData = item['product'];
    final String? imageUrl = productData['image_url'];
    final int cartId = item['id'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: selectedItemIds.contains(cartId),
            onChanged: (bool? value) => toggleSelection(cartId),
            activeColor: const Color(0xFF3F51B5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        buildPlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return buildPlaceholder();
                    },
                  )
                : buildPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productData['name'] ?? '',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item['lens_type'] != null)
                  Text(
                    "+ Lensa ${item['lens_type']['lens_name']}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 💡 UBAH HARGA ITEM DI SINI
                    Text(
                      formatRupiah(itemTotalPrice),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5)),
                    ),

                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: item['qty'] > 1
                                ? () => changeQty(index, -1)
                                : () => removeItem(index),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                item['qty'] > 1
                                    ? Icons.remove
                                    : Icons.delete_outline,
                                size: 16,
                                color: item['qty'] > 1
                                    ? Colors.black87
                                    : Colors.red,
                              ),
                            ),
                          ),
                          Text(
                            "${item['qty']}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          InkWell(
                            onTap: () => changeQty(index, 1),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.add,
                                  size: 16, color: Color(0xFF3F51B5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(double total) {
    bool isAllSelected =
        cartItems.isNotEmpty && selectedItemIds.length == cartItems.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isAllSelected,
                  onChanged: toggleAll,
                  activeColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                const Text("Semua", style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Total Belanja",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                // 💡 UBAH HARGA TOTAL DI SINI
                Text(
                  formatRupiah(total),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5)),
                ),
              ],
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 46,
              width: 120,
              child: ElevatedButton(
                onPressed: selectedItemIds.isEmpty
                    ? null
                    : () {
                        final selectedItems = cartItems
                            .where(
                                (item) => selectedItemIds.contains(item['id']))
                            .toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckoutScreen(selectedItems: selectedItems),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text("Checkout (${selectedItemIds.length})",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 100, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Keranjang masih kosong",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text("Temukan kacamata impianmu sekarang!",
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
