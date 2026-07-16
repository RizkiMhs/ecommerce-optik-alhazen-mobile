import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 💡 IMPORT BARU UNTUK FORMAT HARGA
import 'package:optik_alhazen_app/screens/add_address_screen.dart';
import '../widgets/alhazen_appbar.dart';
import '../services/address_service.dart';
import '../services/order_service.dart';
import '../services/biteship_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';

import '../services/voucher_service.dart'; // 💡 TAMBAHKAN INI

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
  List<dynamic> allAddresses = [];
  bool isLoadingAddress = true;
  bool isSubmitting = false;

  // 💡 STATE BARU UNTUK VOUCHER
  Map<String, dynamic>? appliedVoucher;
  double discountAmount = 0;

  // STATE BARU: Metode Pembayaran
  // 💡 Ubah default metode pembayaran ke BCA
  String selectedPaymentMethod = "Transfer Bank BCA";

  // 💡 Hanya sisakan dua opsi: BCA dan BSI
  final List<Map<String, dynamic>> paymentOptions = [
    {
      "name": "Transfer Bank BCA",
      "code": "bca_va", // Kode resmi Midtrans untuk Virtual Account BCA
      "icon": Icons.account_balance,
      "desc": "Dicek otomatis, tersedia 24 jam"
    },
    {
      "name": "Transfer Bank BSI",
      "code": "bsi_va", // Kode resmi Midtrans untuk Virtual Account BSI
      "icon": Icons.account_balance,
      "desc": "Dicek otomatis, khusus Bank Syariah Indonesia"
    },
    // 💡 TAMBAHAN BARU: Metode Pembayaran QRIS
    {
      "name": "QRIS (Gopay, OVO, Dana, dll)",
      "code": "other_qris", // Kode resmi Midtrans untuk QRIS
      "icon": Icons.qr_code_scanner, // Menggunakan ikon QR Code bawaan Flutter
      "desc": "Scan QR menggunakan aplikasi e-wallet atau m-banking"
    },
  ];

  String selectedCourierCode = "jne";
  String selectedCourierKey = "jne|reg";

  final List<Map<String, String>> courierOptions = [
    {
      "code": "jne",
      "label": "JNE",
    },
    {
      "code": "jnt",
      "label": "J&T Express",
    },
  ];
  @override
  void initState() {
    super.initState();
    fetchUserAddress();
  }

  bool _isMainAddress(dynamic value) {
    if (value is bool) return value;

    if (value is num) {
      return value == 1;
    }

    final normalized = value.toString().trim().toLowerCase();

    return normalized == '1' || normalized == 'true';
  }

  void fetchUserAddress() async {
    final addresses = await AddressService.getAddresses();

    if (!mounted) return;

    setState(() {
      allAddresses = addresses;

      if (addresses.isNotEmpty) {
        mainAddress = addresses.firstWhere(
          (addr) => _isMainAddress(addr['is_main']),
          orElse: () => addresses.first,
        );
      } else {
        mainAddress = null;
      }

      isLoadingAddress = false;
    });

    if (mainAddress != null) {
      final cityId = mainAddress!['city_id'].toString();
      fetchOngkir(cityId);
    } else {
      setState(() => isLoadingShipping = false);
    }
  }

  void fetchOngkir(String cityId) async {
    setState(() {
      isLoadingShipping = true;
      ongkosKirim = 0;
      namaKurir = "Menghitung ongkir...";
      estimasiWaktu = "";
      selectedCourierKey = "";
    });

    final result = await OrderService.checkOngkir(
      cityId,
      selectedCourierCode,
    );

    if (!mounted) return;

    setState(() {
      if (result != null && result['status'] == 'success') {
        ongkosKirim = double.tryParse(
              result['shipping_cost'].toString(),
            ) ??
            0;

        // Bisa membaca format backend lama maupun backend baru
        namaKurir = (result['courier_label'] ??
                result['courier'] ??
                selectedCourierCode.toUpperCase())
            .toString();

        estimasiWaktu = (result['etd'] ?? "-").toString();

        // Wajib agar JNE/J&T tersimpan dengan service-nya
        selectedCourierKey =
            (result['courier_key'] ?? "$selectedCourierCode|reg").toString();
      } else {
        ongkosKirim = 0;
        namaKurir = "Kurir tidak tersedia";
        estimasiWaktu = "";
        selectedCourierKey = "";
      }

      isLoadingShipping = false;
    });
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

  // 💡 FUNGSI BARU: Menampilkan daftar alamat ala Shopee
  // 💡 FUNGSI BARU: Menampilkan daftar alamat ala Shopee (Desain Modern)
  void _showAddressSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Buat transparan agar radius terlihat sempurna
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, // Tinggi 75% layar
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- DRAG HANDLE (Indikator Tarik) ---
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // --- HEADER ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pilih Alamat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A), // Warna teks gelap modern
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddAddressScreen()),
                        );
                        if (result == true) {
                          setState(() => isLoadingAddress = true);
                          fetchUserAddress();
                        }
                      },
                      icon: const Icon(Icons.add,
                          size: 18, color: Color(0xFF3F51B5)),
                      label: const Text(
                        "Tambah",
                        style: TextStyle(
                            color: Color(0xFF3F51B5),
                            fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const Divider(thickness: 1, color: Color(0xFFEEEEEE)),

              // --- DAFTAR ALAMAT ---
              Expanded(
                child: allAddresses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off_rounded,
                                size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text("Belum ada alamat tersimpan.",
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        itemCount: allAddresses.length,
                        itemBuilder: (context, index) {
                          final a = allAddresses[index];
                          bool isSelected = mainAddress != null &&
                              mainAddress!['id'] == a['id'];
                          bool isMain =
                              a['is_main'] == 1 || a['is_main'] == true;

                          String rawLabel = a['label'] ?? 'Alamat';
                          String formattedLabel = rawLabel.isNotEmpty
                              ? '${rawLabel[0].toUpperCase()}${rawLabel.substring(1).toLowerCase()}'
                              : rawLabel;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                setState(() {
                                  mainAddress = a;
                                  isLoadingShipping = true;
                                  ongkosKirim = 0;
                                });
                                Navigator.pop(context);
                                fetchOngkir(a['city_id'].toString());
                              },
                              // 💡 Gunakan AnimatedContainer agar perpindahan warna halus
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade50
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF3F51B5)
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF3F51B5)
                                                .withOpacity(0.15),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ikon Lokasi dengan Lingkaran Background
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF3F51B5)
                                            : Colors.grey.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                formattedLabel,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: isSelected
                                                      ? const Color(0xFF3F51B5)
                                                      : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (isMain)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF3F51B5)
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: const Text(
                                                    "UTAMA",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF3F51B5),
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "${a['recipient_name']}  |  ${a['phone']}",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "${a['complete_address']}\nKode Pos: ${a['postal_code']}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              height: 1.4,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(Icons.check_circle_rounded,
                                            color: Color(0xFF3F51B5), size: 26),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 💡 FUNGSI BARU: Untuk mengubah angka mentah menjadi format Rupiah rapi
  String formatRupiah(dynamic amount) {
    double parsedAmount = double.tryParse(amount.toString()) ?? 0;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(parsedAmount);
  }

  // 💡 FUNGSI BARU: Menampilkan pop-up gambar resep dengan fitur Zoom
  void _showPrescriptionImageDialog(String imagePath) {
    // Membentuk URL lengkap gambar (menghapus '/api' dari baseUrl)
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
            // Container Gambar dengan fitur Zoom (InteractiveViewer)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 1,
                  maxScale: 4,
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
                          Text("Gagal memuat gambar resep",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Tombol Close (X) di pojok kanan atas
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
                  tooltip: 'Tutup',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 FUNGSI MEMUNCULKAN DAFTAR VOUCHER
  // 💡 FUNGSI MEMUNCULKAN DAFTAR VOUCHER
  void _showVoucherSheet(double subtotalProduk) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext sheetContext) {
        return FutureBuilder<List<dynamic>>(
          future: VoucherService.getAvailableVouchers(),
          builder: (contextSnapshot, snapshot) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pilih Voucher Diskon",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (!snapshot.hasData || snapshot.data!.isEmpty)
                    const Center(
                        child: Text("Belum ada promo yang tersedia saat ini."))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (listContext, index) {
                          final v = snapshot.data![index];
                          final minBelanja =
                              double.parse(v['min_purchase'].toString());
                          final bool isEligible = subtotalProduk >= minBelanja;

                          // 💡 LOGIKA FORMAT DISKON (Sama seperti di Profil)
                          final String discountType = v['discount_type'];
                          final double discountValue =
                              double.parse(v['discount_value'].toString());

                          String discountText = "";
                          if (discountType == 'percent') {
                            discountText = "Diskon ${discountValue.toInt()}%";
                          } else {
                            discountText =
                                "Potongan ${formatRupiah(discountValue)}";
                          }

                          return Opacity(
                            opacity: isEligible ? 1.0 : 0.5,
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.red.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(12)),
                              color: Colors.red.shade50,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: const Icon(Icons.local_offer,
                                    color: Colors.redAccent, size: 28),
                                title: Text(v['code'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: Colors.redAccent,
                                        letterSpacing: 1)),

                                // 💡 SUBTITLE DIPERBARUI: Menampilkan Teks Diskon & Min Belanja
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(discountText,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(
                                          "Min. belanja ${formatRupiah(minBelanja)}",
                                          style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),

                                trailing: isEligible
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white),
                                        onPressed: () async {
                                          Navigator.pop(sheetContext);

                                          showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (dialogContext) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                              color: Color(
                                                                  0xFF3F51B5))));

                                          final res = await VoucherService
                                              .verifyVoucher(
                                                  v['code'], subtotalProduk);

                                          Navigator.pop(context);

                                          if (res['status'] == 'success') {
                                            setState(() {
                                              appliedVoucher =
                                                  res['data']['voucher'];
                                              discountAmount = double.parse(
                                                  res['data']['discount_amount']
                                                      .toString());
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Hore! Voucher berhasil dipakai 🎉"),
                                                    backgroundColor:
                                                        Colors.green));
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content:
                                                        Text(res['message']),
                                                    backgroundColor:
                                                        Colors.red));
                                          }
                                        },
                                        child: const Text("Pakai"),
                                      )
                                    : const Text("Tidak Memenuhi",
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.red)),
                              ),
                            ),
                          );
                        },
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
    double subtotalProduk = widget.selectedItems.fold(0, (sum, item) {
      double base = double.parse(item['product']['base_price'].toString());
      double lens = double.parse(
          (item['lens_type']?['additional_price'] ?? 0).toString());
      return sum + ((base + lens) * item['qty']);
    });

    // 💡 UPDATE: Grand Total sekarang dikurangi diskon
    double grandTotal = (subtotalProduk - discountAmount) + ongkosKirim;
    if (grandTotal < 0) grandTotal = 0; // Jaga-jaga agar tidak minus

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
          // const SizedBox(height: 8),
          _buildVoucherSection(subtotalProduk),
          const SizedBox(height: 8),
          _buildCourierSection(),
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
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          if (isLoadingAddress) return;

          if (mainAddress != null) {
            // 💡 PERUBAHAN: Panggil Bottom Sheet untuk memilih alamat, bukan pindah ke AddAddressScreen
            _showAddressSelectionSheet();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF3F51B5)),
              const SizedBox(width: 12),
              Expanded(
                child: isLoadingAddress
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF3F51B5)))
                    : mainAddress != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Alamat Pengiriman",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                  "${mainAddress!['recipient_name']} (${mainAddress!['phone']})",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                  "${mainAddress!['complete_address']}, Kode Pos: ${mainAddress!['postal_code']}",
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.4)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Alamat Pengiriman",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
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
              // Ikon panah ke kanan agar user tahu ini bisa diklik
              if (mainAddress != null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
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
          item['note'] != null ||
          (item['prescription_image'] != null &&
              item['prescription_image'].toString().isNotEmpty);
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

                  // 💡 TOMBOL LIHAT FOTO RESEP YANG SUDAH DIPERCANTIK MALAM INI
                  if (item['prescription_image'] != null &&
                      item['prescription_image'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: InkWell(
                        onTap: () => _showPrescriptionImageDialog(
                            item['prescription_image']),
                        borderRadius: BorderRadius.circular(10),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3F51B5).withOpacity(
                                0.06), // Background indigo super soft
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF3F51B5)
                                  .withOpacity(0.2), // Border tipis transparan
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_search_rounded,
                                size: 18,
                                color: Color(0xFF3F51B5), // Ikon berwarna tajam
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Lihat Foto Resep",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w800, // Teks tebal & tegas
                                  color: Color(0xFF3F51B5),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

  // 💡 UI TOMBOL VOUCHER DI CHECKOUT
  Widget _buildVoucherSection(double subtotalProduk) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _showVoucherSheet(subtotalProduk),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                appliedVoucher != null
                    ? "Voucher Dipakai: ${appliedVoucher!['code']}"
                    : "Gunakan Promo / Voucher",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        appliedVoucher != null ? Colors.green : Colors.black87),
              ),
            ),
            if (appliedVoucher != null)
              Text("- ${formatRupiah(discountAmount)} ",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
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
                          Text("Estimasi tiba: $estimasiWaktu",
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

          // 1. Subtotal Produk
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal Produk",
                  style: TextStyle(color: Colors.grey)),
              Text(formatRupiah(subtotalProduk)),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Subtotal Pengiriman
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal Pengiriman",
                  style: TextStyle(color: Colors.grey)),
              isLoadingShipping
                  ? const Text("Menghitung...",
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic))
                  : Text(formatRupiah(ongkosKirim)),
            ],
          ),

          // 💡 3. TAMBAHAN BARU: Diskon Voucher (Hanya muncul jika ada diskon)
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Diskon Voucher",
                    style: TextStyle(color: Colors.grey)),
                Text(
                  "- ${formatRupiah(discountAmount)}",
                  style: TextStyle(color: const Color.fromARGB(255, 255, 0, 0)),
                ),
              ],
            ),
          ],
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

                        final selectedCode = paymentOptions.firstWhere(
                          (p) => p['name'] == selectedPaymentMethod,
                        )['code'];

                        final selectedCartIds = widget.selectedItems
                            .map((item) => item['id'])
                            .where((id) => id != null)
                            .toList();

                        print("SELECTED CART IDS:");
                        print(selectedCartIds);

                        final result = await OrderService.submitOrder(
                          shippingCost: ongkosKirim,
                          courier: selectedCourierKey,
                          paymentMethod: selectedCode,
                          addressData: mainAddress!,
                          cartIds: selectedCartIds,
                          voucherCode: appliedVoucher?['code'],
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

  Widget _buildCourierSection() {
    final bool courierReady = !isLoadingShipping &&
        namaKurir.isNotEmpty &&
        namaKurir != "Kurir tidak tersedia" &&
        namaKurir != "Menghitung ongkir...";

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFF3F51B5),
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                "Pilih Ekspedisi",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF202124),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            "Pilih kurir untuk pengiriman pesanan Anda",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: courierOptions.map((courier) {
              final bool isSelected = selectedCourierCode == courier['code'];

              final bool isJne = courier['code'] == 'jne';

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isJne ? 10 : 0,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (mainAddress == null) return;

                      setState(() {
                        selectedCourierCode = courier['code']!;
                        selectedCourierKey = "";
                        ongkosKirim = 0;
                        namaKurir = "Menghitung ongkir...";
                        estimasiWaktu = "";
                        isLoadingShipping = true;
                      });

                      fetchOngkir(
                        mainAddress!['city_id'].toString(),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF3F51B5) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3F51B5)
                              : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF3F51B5).withOpacity(0.20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.local_shipping_outlined,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3F51B5),
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              courier['label']!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF303030),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isLoadingShipping
                  ? Colors.grey.shade50
                  : courierReady
                      ? const Color(0xFFF3F6FF)
                      : const Color(0xFFFFF4F4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isLoadingShipping
                    ? Colors.grey.shade200
                    : courierReady
                        ? const Color(0xFFD5DFFF)
                        : const Color(0xFFFFD4D4),
              ),
            ),
            child: isLoadingShipping
                ? const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Menghitung ongkir terbaik...",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  )
                : courierReady
                    ? Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F51B5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  namaKurir,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: Color(0xFF202124),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                if (estimasiWaktu.isNotEmpty)
                                  Text(
                                    "Estimasi tiba: $estimasiWaktu",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            formatRupiah(ongkosKirim),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.redAccent,
                            size: 21,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              namaKurir.isEmpty
                                  ? "Kurir belum tersedia untuk alamat ini"
                                  : namaKurir,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
