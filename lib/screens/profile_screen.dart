import 'package:flutter/material.dart';
import 'package:optik_alhazen_app/screens/add_address_screen.dart';
import 'package:optik_alhazen_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/profile_service.dart';

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

  // 💡 LOGIKA BARU: Mengambil nomor telepon dari tabel alamat
  String get _displayPhone {
    if (addresses.isEmpty) return 'Tidak ada nomor telepon';
    try {
      // Cari alamat utama (is_main == 1), jika tidak ada, ambil alamat pertama saja
      final mainAddr = addresses.firstWhere(
        (a) => a['is_main'] == 1,
        orElse: () => addresses[0],
      );
      return mainAddr['phone'] ?? 'Tidak ada nomor telepon';
    } catch (e) {
      return 'Tidak ada nomor telepon';
    }
  }

  // 💡 FUNGSI BARU: Menampilkan Dialog Ganti Password
  // 💡 FUNGSI DIALOG GANTI PASSWORD YANG DIPERBARUI
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
      barrierDismissible: false, // Tidak bisa ditutup dengan klik luar area
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
                // --- 1. PASSWORD LAMA ---
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

                // --- 2. PASSWORD BARU ---
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

                // --- 3. KONFIRMASI PASSWORD BARU ---
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
                      // 💡 Validasi Input
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

                      // 💡 Panggil API
                      bool success = await ProfileService.updatePassword(
                          user!['name'],
                          oldPasswordController.text,
                          newPasswordController.text);

                      setStateDialog(() => isUpdating = false);

                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Password berhasil diubah!"),
                              backgroundColor: Colors.green),
                        );
                      } else {
                        // Jika false, kemungkinan besar password lama salah
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
      backgroundColor: const Color(
          0xFFF5F7FA), // Latar belakang abu-abu sangat muda (modern)
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION (Lengkungan Biru di Atas) ---
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
                  // 💡 HAPUS ICON BACK & EDIT: Hanya Teks Saja
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

                  // Avatar Profil
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person,
                          size: 55, color: Color(0xFF3F51B5)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama & Email
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
                  // 💡 KARTU QUOTE OPTIK ALHAZEN
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

                  // 💡 KARTU MENU PENGATURAN (Telp & Password)
                  // 💡 KARTU MENU PENGATURAN (Telp & Password)
                  const Text("Pengaturan Akun",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    // 💡 PERBAIKAN: Tambahkan padding atas dan bawah di sini agar seimbang
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: _cardBorderRadius,
                      boxShadow: _cardShadow,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          // 💡 vertical diubah jadi 0 agar patuh pada padding Container
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
                          subtitle: Text(_displayPhone,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600)),
                        ),

                        Divider(
                            height: 16,
                            indent: 70,
                            endIndent: 20,
                            color: Colors.grey
                                .shade200), // height divider sedikit dilebarkan

                        ListTile(
                          // 💡 vertical diubah jadi 0 agar patuh pada padding Container
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 💡 DAFTAR ALAMAT
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
                      bool isMain = a['is_main'] == 1;
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

                  // 💡 TOMBOL LOGOUT MERAH
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
