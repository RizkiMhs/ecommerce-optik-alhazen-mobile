import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:optik_alhazen_app/screens/add_address_screen.dart';
import 'package:optik_alhazen_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_service.dart';

import 'package:flutter/services.dart'; // Untuk fitur copy kode voucher
import 'package:intl/intl.dart'; // Untuk format Rupiah
import '../services/voucher_service.dart'; // Memanggil API Voucher
import '../colect/faq_screen.dart'; // Sesuaikan path-nya

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  List addresses = [];

  final List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  final BorderRadius _cardBorderRadius = BorderRadius.circular(20);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final u = await ProfileService.getProfile();
    final a = await ProfileService.getAddresses();

    if (mounted) {
      setState(() {
        user = u;
        addresses = a;
      });
    }
  }

  String get _displayPhone {
    if (addresses.isEmpty) return 'Tidak ada nomor telepon';
    try {
      final mainAddr = addresses.firstWhere(
        (a) => a['is_main'] == 1,
        orElse: () => addresses[0],
      );
      return mainAddr['phone'] ?? 'Tidak ada nomor telepon';
    } catch (e) {
      return 'Tidak ada nomor telepon';
    }
  }

  // 💡 FUNGSI BARU: Menampilkan Daftar Voucher Aktif di Profil
  void _showVouchersSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- DRAG HANDLE ---
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text("Promo & Voucher Aktif",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(thickness: 1, color: Color(0xFFEEEEEE)),

                // --- LIST VOUCHER (DARI API) ---
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                      future: VoucherService.getAvailableVouchers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF3F51B5)));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_offer_outlined,
                                    size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text("Belum ada promo saat ini.",
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 16)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final v = snapshot.data![index];
                            final minBelanja =
                                double.parse(v['min_purchase'].toString());

                            // Format Rupiah untuk Min. Belanja
                            final formattedMinBelanja = NumberFormat.currency(
                                    locale: 'id_ID',
                                    symbol: 'Rp ',
                                    decimalDigits: 0)
                                .format(minBelanja);

                            // 💡 LOGIKA BARU: Menentukan Tampilan Nominal/Persen Diskon
                            final String discountType = v['discount_type'];
                            final double discountValue =
                                double.parse(v['discount_value'].toString());

                            String discountText = "";
                            if (discountType == 'percent') {
                              // Jika diskon berupa persen (menghilangkan angka desimal .00)
                              discountText = "Diskon ${discountValue.toInt()}%";
                            } else {
                              // Jika diskon berupa potongan harga (diformat ke Rupiah)
                              final formattedDiscount = NumberFormat.currency(
                                      locale: 'id_ID',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(discountValue);
                              discountText = "Potongan $formattedDiscount";
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.red.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(12)),
                              color: Colors.red.shade50,
                              elevation: 0,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical:
                                        8), // Padding vertikal sedikit ditambah
                                leading: const Icon(Icons.local_offer,
                                    color: Colors.redAccent, size: 28),
                                title: Text(v['code'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        color: Colors.redAccent,
                                        letterSpacing: 1)),

                                // 💡 TAMPILAN SUBTITLE YANG BARU (Berisi Diskon & Syarat)
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
                                      Text("Min. belanja $formattedMinBelanja",
                                          style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),

                                // trailing: OutlinedButton(
                                //   onPressed: () {
                                //     // 💡 Fitur Salin Kode
                                //     Clipboard.setData(
                                //         ClipboardData(text: v['code']));
                                //     Navigator.pop(context); // Tutup sheet
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       SnackBar(
                                //           content: Text(
                                //               "Kode ${v['code']} berhasil disalin!"),
                                //           backgroundColor: Colors.green),
                                //     );
                                //   },
                                //   style: OutlinedButton.styleFrom(
                                //       side: const BorderSide(
                                //           color: Colors.redAccent),
                                //       shape: RoundedRectangleBorder(
                                //           borderRadius:
                                //               BorderRadius.circular(8)),
                                //       minimumSize: const Size(60, 32),
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 12)),
                                //   child: const Text("SALIN",
                                //       style: TextStyle(
                                //           color: Colors.redAccent,
                                //           fontSize: 12,
                                //           fontWeight: FontWeight.bold)),
                                // ),
                              ),
                            );
                          },
                        );
                      }),
                ),
              ],
            ),
          );
        });
  }

  // 💡 FUNGSI BARU: Dialog Edit Profil Dasar (Nama, Email, dan Foto)
  void _showEditProfileDialog() {
    final TextEditingController nameController =
        TextEditingController(text: user!['name']);
    final TextEditingController emailController =
        TextEditingController(text: user!['email']);
    // 💡 1. TAMBAHKAN CONTROLLER TELEPON
    // 💡 PERBAIKAN: Ambil HP dari tabel users. Jika kosong, tarik dari alamat.
    String initialPhone =
        (user!['phone'] != null && user!['phone'].toString().isNotEmpty)
            ? user!['phone'].toString()
            : (_displayPhone != 'Tidak ada nomor telepon' ? _displayPhone : '');
    final TextEditingController phoneController =
        TextEditingController(text: initialPhone);

    File? newAvatar;
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Profil",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AREA FOTO PROFIL
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (pickedFile != null) {
                      setStateDialog(() {
                        newAvatar = File(pickedFile.path);
                      });
                    }
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage: newAvatar != null
                              ? FileImage(newAvatar!)
                              : (user!['avatar_url'] != null
                                  ? NetworkImage(user!['avatar_url'])
                                  : null) as ImageProvider?,
                          child:
                              newAvatar == null && user!['avatar_url'] == null
                                  ? const Icon(Icons.person,
                                      size: 40, color: Colors.grey)
                                  : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: Color(0xFF3F51B5), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 14),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Ketuk foto untuk mengubah",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 24),

                // AREA NAMA
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // AREA EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                // 💡 2. TAMBAHKAN AREA NOMOR TELEPON DI BAWAH EMAIL
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Nomor Telepon",
                    prefixIcon:
                        const Icon(Icons.phone_outlined, color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isUpdating
                  ? null
                  : () async {
                      if (nameController.text.isEmpty ||
                          emailController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Nama dan Email tidak boleh kosong!"),
                                backgroundColor: Colors.red));
                        return;
                      }

                      setStateDialog(() => isUpdating = true);

                      bool success = await ProfileService.updateFullProfile(
                        name: nameController.text,
                        email: emailController.text,
                        phone: phoneController.text,
                        avatarFile: newAvatar,
                      );

                      setStateDialog(() => isUpdating = false);

                      if (success) {
                        Navigator.pop(context);
                        loadData(); // Refresh UI profile
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Profil berhasil diperbarui!"),
                              backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Gagal memperbarui profil. Email mungkin sudah dipakai."),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
              child: isUpdating
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    bool isUpdating = false;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Ganti Password",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: obscureOld,
                  decoration: InputDecoration(
                    labelText: "Password Lama",
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureOld ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                          size: 20),
                      onPressed: () =>
                          setStateDialog(() => obscureOld = !obscureOld),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: "Password Baru",
                    prefixIcon:
                        const Icon(Icons.lock_reset, color: Color(0xFF3F51B5)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                          size: 20),
                      onPressed: () =>
                          setStateDialog(() => obscureNew = !obscureNew),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: "Konfirmasi Password Baru",
                    prefixIcon: const Icon(Icons.check_circle_outline,
                        color: Color(0xFF3F51B5)),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                          size: 20),
                      onPressed: () => setStateDialog(
                          () => obscureConfirm = !obscureConfirm),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isUpdating
                  ? null
                  : () async {
                      if (oldPasswordController.text.isEmpty ||
                          newPasswordController.text.isEmpty ||
                          confirmPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Semua kolom harus diisi!"),
                                backgroundColor: Colors.red));
                        return;
                      }
                      if (newPasswordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Password baru minimal 6 karakter!"),
                                backgroundColor: Colors.red));
                        return;
                      }
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Password baru dan konfirmasi tidak cocok!"),
                                backgroundColor: Colors.red));
                        return;
                      }

                      setStateDialog(() => isUpdating = true);

                      bool success = await ProfileService.updateFullProfile(
                          name: user!['name'],
                          email: user!['email'],
                          oldPassword: oldPasswordController.text,
                          newPassword: newPasswordController.text);

                      setStateDialog(() => isUpdating = false);

                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Password berhasil diubah!"),
                              backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Gagal mengubah. Pastikan password lama Anda benar!"),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
              child: isUpdating
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar Akun'),
            content:
                const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    const Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child:
                    const Text('Keluar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF3F51B5))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, bottom: 40, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF3F51B5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "PROFIL SAYA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Avatar Profil yang diperbarui (Menampilkan foto dari server jika ada)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: user!['avatar_url'] != null
                              ? NetworkImage(user!['avatar_url'])
                              : null,
                          child: user!['avatar_url'] == null
                              ? const Icon(Icons.person,
                                  size: 55, color: Color(0xFF3F51B5))
                              : null,
                        ),
                      ),
                      // Tombol pensil kecil untuk edit profil cepat
                      GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Color(0xFF3F51B5), size: 16),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    user!['name'] ?? 'Pengguna',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user!['email'] ?? 'Tidak ada email',
                      style: TextStyle(fontSize: 14, color: Colors.blue[50]),
                    ),
                  ),
                ],
              ),
            ),

            // --- BODY SECTION ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: _cardBorderRadius,
                      boxShadow: _cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.remove_red_eye_rounded,
                              color: Color(0xFF3F51B5), size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "Melihat dunia lebih jelas dan indah bersama Optik Alhazen. Kami siap melayani kebutuhan penglihatan Anda.",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                height: 1.5,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 💡 KARTU BARU: PROMO & VOUCHER
                  const Text("Dompet & Promo",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: _cardBorderRadius,
                      boxShadow: _cardShadow,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.local_offer_rounded,
                            color: Colors.redAccent),
                      ),
                      title: const Text("Voucher Diskon",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text("Klaim dan gunakan promo menarik",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                      // 💡 UBAH BAGIAN INI
                      onTap: () {
                        _showVouchersSheet();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Di bawah ini adalah "Pengaturan Akun" yang sudah ada...
                  const Text("Pengaturan Akun",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: _cardBorderRadius,
                      boxShadow: _cardShadow,
                    ),
                    child: Column(
                      children: [
                        // Tombol Edit Profil Dasar
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.person,
                                color: Color(0xFF3F51B5)),
                          ),
                          title: const Text("Edit Data Profil",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: Colors.grey),
                          onTap: _showEditProfileDialog,
                        ),

                        Divider(
                            height: 16,
                            indent: 70,
                            endIndent: 20,
                            color: Colors.grey.shade200),

                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.phone_rounded,
                                color: Colors.green),
                          ),
                          title: const Text("Nomor Telepon",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              (user!['phone'] != null &&
                                      user!['phone'].toString().isNotEmpty)
                                  ? user!['phone']
                                  : _displayPhone, // Gunakan dari alamat jika akun belum diatur
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600)),
                        ),
                        Divider(
                            height: 16,
                            indent: 70,
                            endIndent: 20,
                            color: Colors.grey.shade200),

                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 0),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.lock_rounded,
                                color: Colors.orange),
                          ),
                          title: const Text("Ganti Password",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: Colors.grey),
                          onTap: _showChangePasswordDialog,
                        ),

                        // Divider(
                        //     height: 16,
                        //     indent: 70,
                        //     endIndent: 20,
                        //     color: Colors.grey.shade200),

                        // ListTile(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => const FaqScreen()),
                        //     );
                        //   },
                        //   leading: Container(
                        //     padding: const EdgeInsets.all(8),
                        //     decoration: BoxDecoration(
                        //       color: Colors.blue.shade50,
                        //       borderRadius: BorderRadius.circular(8),
                        //     ),
                        //     child: const Icon(Icons.help_outline_rounded,
                        //         color: Colors.blue),
                        //   ),
                        //   title: const Text("Pusat Bantuan (FAQ)",
                        //       style: TextStyle(fontWeight: FontWeight.w600)),
                        //   trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        //       size: 16, color: Colors.grey),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Daftar Alamat",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AddAddressScreen()));
                          if (result == true) loadData();
                        },
                        child: const Text("+ Tambah",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5))),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (addresses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text("Belum ada alamat tersimpan.",
                            style: TextStyle(color: Colors.grey.shade500)),
                      ),
                    )
                  else
                    ...addresses.map((a) {
                      final mainValue = a['is_main'];

                      final bool isMain = mainValue == true ||
                          mainValue == 1 ||
                          mainValue == '1' ||
                          mainValue.toString().toLowerCase() == 'true';
                      String rawLabel = a['label'] ?? 'Alamat';
                      String formattedLabel = rawLabel.isNotEmpty
                          ? '${rawLabel[0].toUpperCase()}${rawLabel.substring(1).toLowerCase()}'
                          : rawLabel;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: _cardBorderRadius,
                          border: Border.all(
                              color: isMain
                                  ? const Color(0xFF3F51B5)
                                  : Colors.transparent,
                              width: 1.5),
                          boxShadow: _cardShadow,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded,
                                      color: isMain
                                          ? const Color(0xFF3F51B5)
                                          : Colors.grey,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    formattedLabel,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[900]),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isMain)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: const Text("Utama",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF3F51B5))),
                                    ),
                                  const Spacer(),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded,
                                        color: Colors.grey),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    AddAddressScreen(data: a)));
                                        if (result == true) loadData();
                                      } else if (value == 'delete') {
                                        await ProfileService.deleteAddress(
                                            a['id']);
                                        loadData();
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                          value: 'edit', child: Text('Ubah')),
                                      const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Hapus',
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 28, top: 4),
                                child: Text(
                                  a['complete_address'] ??
                                      'Alamat tidak lengkap',
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                      height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded,
                          color: Colors.redAccent),
                      label: const Text(
                        "Keluar Akun",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: Colors.red.shade200, width: 1.5),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
