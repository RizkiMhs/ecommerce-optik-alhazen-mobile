class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double basePrice;
  final String? lensName;
  final double additionalPrice;
  int qty;
  // Data Resep
  final String? sphRight;
  final String? sphLeft;
  final String? pd;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.basePrice,
    this.lensName,
    this.additionalPrice = 0,
    required this.qty,
    this.sphRight,
    this.sphLeft,
    this.pd,
  });

  // Fungsi untuk menghitung harga total satu item (Frame + Lensa) * Qty
  double get totalPrice => (basePrice + additionalPrice) * qty;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product']['name'],
      productImage: json['product']['image_url'], // Sesuaikan dengan API kamu
      basePrice: double.parse(json['product']['base_price'].toString()),
      lensName: json['lens_type']?['lens_name'],
      additionalPrice: double.parse((json['lens_type']?['additional_price'] ?? 0).toString()),
      qty: json['qty'],
      sphRight: json['sph_right'],
      sphLeft: json['sph_left'],
      pd: json['pd'],
    );
  }
}