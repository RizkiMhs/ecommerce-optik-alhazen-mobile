import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 💡 IMPORT BARU UNTUK FORMAT HARGA
import 'package:optik_alhazen_app/screens/add_address_screen.dart';
import '../widgets/alhazen_appbar.dart';
import '../services/address_service.dart';
import '../services/order_service.dart';
import '../services/biteship_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:optik_alhazen_app/screens/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> selectedItems;

  const CheckoutScreen({super.key, required this.selectedItems});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // State Ongkir
  double ongkosKirim = 0;
  String namaKurir = "Menghitung ongkos kirim...";
  String estimasiWaktu = "";
  bool isLoadingShipping = true;

  // State Alamat
  Map<String, dynamic>? mainAddress;
  bool isLoadingAddress = true;
  bool isSubmitting = false;

  // STATE BARU: Metode Pembayaran
  String selectedPaymentMethod = "QRIS";
  final List<Map<String, dynamic>> paymentOptions = [
    {
      "name": "QRIS",
      "icon": Icons.qr_code_2,
      "desc": "Bayar instan pakai e-wallet/m-banking"
    },
    {
      "name": "Transfer Bank BCA",
      "icon": Icons.account_balance,
      "desc": "Dicek otomatis"
    },
    {
      "name": "Transfer Bank Mandiri",
      "icon": Icons.account_balance,
      "desc": "Dicek otomatis"
    },
    {
      "name": "GoPay",
      "icon": Icons.account_balance_wallet,
      "desc": "Bayar instan"
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  void fetchUserAddress() async {
    final addresses = await AddressService.getAddresses();

    if (mounted) {
      setState(() {
        if (addresses.isNotEmpty) {
          mainAddress = addresses.firstWhere(
              (addr) => addr['is_main'] == 1 || addr['is_main'] == true,
              orElse: () => addresses.first);
        } else {
          mainAddress = null;
        }
        isLoadingAddress = false;
      });

      if (mainAddress != null) {
        String cityId = mainAddress!['city_id'].toString();
        fetchOngkir(cityId);
      } else {
        setState(() => isLoadingShipping = false);
      }
    }
  }

  void fetchOngkir(String cityId) async {
    setState(() {
      isLoadingShipping = true;
    });

    final result = await OrderService.checkOngkir(cityId);

    if (mounted) {
      setState(() {
        if (result != null && result['status'] == 'success') {
          ongkosKirim = double.parse(result['shipping_cost'].toString());

          namaKurir = result['courier'];

          estimasiWaktu = result['etd'] ?? "2-3";
        } else {
          namaKurir = "Gagal memuat ongkos kirim";
          ongkosKirim = 0;
        }
        isLoadingShipping = false;
      });
    }
  }

  void _showPaymentMethodSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Pilih Metode Pembayaran",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...paymentOptions.map((method) {
                  return ListTile(
                    leading:
                        Icon(method['icon'], color: const Color(0xFF3F51B5)),
                    title: Text(method['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(method['desc'],
                        style: const TextStyle(fontSize: 12)),
                    trailing: selectedPaymentMethod == method['name']
                        ? const Icon(Icons.check_circle,
                            color: Color(0xFF3F51B5))
                        : null,
                    onTap: () {
                      setState(() => selectedPaymentMethod = method['name']);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          );
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
    double subtotalProduk = widget.selectedItems.fold(0, (sum, item) {
      double base = double.parse(item['product']['base_price'].toString());
      double lens = double.parse(
          (item['lens_type']?['additional_price'] ?? 0).toString());
      return sum + ((base + lens) * item['qty']);
    });

    double grandTotal = subtotalProduk + ongkosKirim;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AlhazenAppBar(title: "Checkout", showCart: false),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _buildAddressSection(),
          const SizedBox(height: 8),
          _buildOrderItemsSection(),
          const SizedBox(height: 8),
          _buildPrescriptionSection(),
          const SizedBox(height: 8),
          _buildPaymentMethodSection(),
          const SizedBox(height: 8),
          _buildPaymentSummarySection(subtotalProduk),
        ],
      ),
      bottomSheet: _buildBottomBar(grandTotal),
    );
  }

  // --- KOMPONEN UI ---

  Widget _buildAddressSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Color(0xFF3F51B5)),
          const SizedBox(width: 12),
          Expanded(
            child: isLoadingAddress
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
                : mainAddress != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Alamat Pengiriman",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                              "${mainAddress!['recipient_name']} (${mainAddress!['phone']})",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                              "${mainAddress!['complete_address']}, Kode Pos: ${mainAddress!['postal_code']}",
                              style:
                                  const TextStyle(fontSize: 13, height: 1.4)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Alamat Pengiriman",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddAddressScreen()),
                              );
                              if (result == true) {
                                setState(() => isLoadingAddress = true);
                                fetchUserAddress();
                              }
                            },
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text("Tambah Alamat Pengiriman"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[50],
                              foregroundColor: const Color(0xFF3F51B5),
                              elevation: 0,
                            ),
                          )
                        ],
                      ),
          ),
          if (mainAddress != null)
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.storefront, color: Color(0xFF3F51B5)),
                SizedBox(width: 8),
                Text("Optik Alhazen Official",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(),
          ...widget.selectedItems.map((item) {
            final productData = item['product'];
            double basePrice =
                double.parse(productData['base_price'].toString());
            double lensPrice = double.parse(
                (item['lens_type']?['additional_price'] ?? 0).toString());
            double totalPrice = basePrice + lensPrice;
            final String? imageUrl = productData['image_url'];

            final resep = item['prescription'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                buildImagePlaceholder(),
                            loadingBuilder: (ctx, child, progress) =>
                                progress == null
                                    ? child
                                    : buildImagePlaceholder(),
                          )
                        : buildImagePlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productData['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        if (item['lens_type'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                                "Lensa: ${item['lens_type']['lens_name']}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ),
                        if (resep != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.assignment,
                                        size: 14, color: Color(0xFF3F51B5)),
                                    SizedBox(width: 4),
                                    Text("Detail Resep Mata",
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF3F51B5))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  resep.toString(),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[700],
                                      height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 💡 FORMAT RUPIAH DITERAPKAN DI SINI
                            Text(formatRupiah(totalPrice),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3F51B5),
                                    fontSize: 15)),
                            Text("x${item['qty']}",
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPrescriptionSection() {
    final itemsWithPrescription = widget.selectedItems.where((item) {
      return item['sph_right'] != null ||
          item['sph_left'] != null ||
          item['cyl_right'] != null ||
          item['cyl_left'] != null ||
          item['pd'] != null ||
          item['note'] != null;
    }).toList();

    if (itemsWithPrescription.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_ind_outlined,
                  color: Color(0xFF3F51B5), size: 20),
              SizedBox(width: 8),
              Text("Detail Resep Mata",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          ...itemsWithPrescription.map((item) {
            final productName = item['product']['name'] ?? 'Kacamata';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Untuk: $productName",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF3F51B5))),
                  const Divider(
                      height: 16, thickness: 0.5, color: Colors.blueGrey),
                  if (item['sph_right'] != null ||
                      item['cyl_right'] != null ||
                      item['axis_right'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                          "Kanan (R) : SPH ${item['sph_right'] ?? '0'} | CYL ${item['cyl_right'] ?? '0'} | AXIS ${item['axis_right'] ?? '0'}",
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[800])),
                    ),
                  if (item['sph_left'] != null ||
                      item['cyl_left'] != null ||
                      item['axis_left'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                          "Kiri (L)  : SPH ${item['sph_left'] ?? '0'} | CYL ${item['cyl_left'] ?? '0'} | AXIS ${item['axis_left'] ?? '0'}",
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[800])),
                    ),
                  if (item['pd'] != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text("PD : ${item['pd']}",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[800]))),
                  if (item['note'] != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text("Catatan : ${item['note']}",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                                fontStyle: FontStyle.italic))),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Metode Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          InkWell(
            onTap: _showPaymentMethodSheet,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment,
                          color: Color(0xFF3F51B5), size: 20),
                      const SizedBox(width: 12),
                      Text(selectedPaymentMethod,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummarySection(double subtotalProduk) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Opsi Pengiriman",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              isLoadingShipping
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF3F51B5)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(namaKurir,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5))),
                        if (estimasiWaktu.isNotEmpty)
                          Text("Estimasi tiba: $estimasiWaktu hari",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                      ],
                    ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text("Rincian Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal Produk",
                  style: TextStyle(color: Colors.grey)),
              // 💡 FORMAT RUPIAH DITERAPKAN DI SINI
              Text(formatRupiah(subtotalProduk)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal Pengiriman",
                  style: TextStyle(color: Colors.grey)),
              isLoadingShipping
                  ? const Text("Menghitung...",
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic))
                  // 💡 FORMAT RUPIAH DITERAPKAN DI SINI
                  : Text(formatRupiah(ongkosKirim)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double grandTotal) {
    bool isAddressReady = mainAddress != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Pembayaran",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                // 💡 FORMAT RUPIAH DITERAPKAN DI SINI
                Text(
                  formatRupiah(grandTotal),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isAddressReady
                          ? const Color(0xFF3F51B5)
                          : Colors.grey),
                ),
              ],
            ),
            SizedBox(
              height: 46,
              width: 150,
              child: ElevatedButton(
                onPressed: (isAddressReady &&
                        !isLoadingShipping &&
                        !isSubmitting)
                    ? () async {
                        setState(() => isSubmitting = true);

                        final result = await OrderService.submitOrder(
                          shippingCost: ongkosKirim,
                          courier: "jne",
                          paymentMethod: selectedPaymentMethod,
                          addressData: mainAddress!,
                        );

                        setState(() => isSubmitting = false);

                        if (result['status'] == 'success') {
                          final String snapToken = result['payment_token'];

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Pesanan berhasil! Mengalihkan ke pembayaran..."),
                              backgroundColor: Colors.green,
                            ),
                          );

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PaymentScreen(snapToken: snapToken),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  result['message'] ?? "Gagal membuat pesanan"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  disabledBackgroundColor: Colors.grey[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Buat Pesanan",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
          color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.image_outlined, color: Color(0xFF3F51B5)),
    );
    
  }
}
