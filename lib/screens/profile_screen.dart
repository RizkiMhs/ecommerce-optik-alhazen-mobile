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

  // Mendefinisikan gaya bayangan kartu secara global agar konsisten
  final List<BoxShadow> _cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  // Mendefinisikan radius sudut secara global agar konsisten
  final BorderRadius _cardBorderRadius = BorderRadius.circular(16);

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

  Future<void> _logout() async {
    // 💡 Tampilkan dialog konfirmasi sebelum logout
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Keluar'),
            content:
                const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    const Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang biru di bagian atas (seperti referensi)
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: Color(0xFF3F51B5),
          ),

          // Konten utama yang dapat digulir
          SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // App Bar Modern buatan sendiri (ikon kembali, profil, ikon edit)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      "PROFIL",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // Tidak ada logika yang ditentukan untuk ini di kode asli,
                        // tetapi ikonnya ada di referensi.
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Kartu Profil Utama (dengan foto melingkar, nama, dan detail dummy)
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _cardBorderRadius,
                    boxShadow: _cardShadow,
                  ),
                  child: Column(
                    children: [
                      // Foto Profil Melingkar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue[100],
                        child: Icon(Icons.person,
                            size: 60, color: Colors.blue[600]),
                      ),
                      SizedBox(height: 16),

                      // Nama Pengguna (Teks tebal, gelap)
                      Text(
                        user!['name'] ?? 'Pengguna',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                      SizedBox(height: 4),

                      // Detail Sekunder Dummy (gaya referensi 'STD - 12(B)')
                      Text(
                        "Pelanggan Optik",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),

                      // Teks Dummy Bergaya 'Lorem Ipsum'
                      Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Bagian Informasi Kontak (dengan ikon dan teks untuk email dan telepon dummy)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _cardBorderRadius,
                    boxShadow: _cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris Telepon (dummy)
                      Row(
                        children: [
                          Icon(Icons.phone, color: Color(0xFF3F51B5), size: 20),
                          SizedBox(width: 12),
                          Text(
                            user!['phone'] ?? 'Tidak ada nomor telepon',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Baris Email (dari data asli)
                      Row(
                        children: [
                          Icon(Icons.email, color: Color(0xFF3F51B5), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              user!['email'] ?? 'Tidak ada email',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Judul "Alamat" bergaya modern
                Text(
                  "Alamat",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 12),

                // Daftar Alamat (kartu alamat yang dimodernisasi)
// Daftar Alamat (kartu alamat yang dimodernisasi)
                ...addresses.map((a) {
                  bool isMain = a['is_main'] == 1;
                  // Ambil teks asli
                  String rawLabel = a['label'] ?? 'Alamat';

                  // Format huruf pertama jadi kapital, sisanya kecil
                  String formattedLabel = rawLabel.isNotEmpty
                      ? '${rawLabel[0].toUpperCase()}${rawLabel.substring(1).toLowerCase()}'
                      : rawLabel;
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isMain ? Colors.blue[50] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMain ? Colors.blue[300]! : Colors.grey[200]!,
                        width: isMain ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- BARIS ATAS: Label, Badge "Utama", dan Aksi ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Judul Alamat (Label)
                              Text(
                                formattedLabel,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              SizedBox(width: 8),

                              // Badge "Utama" (Hanya muncul jika isMain == true)
                              if (isMain)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "Utama",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),

                              Spacer(), // Mendorong tombol aksi ke pojok kanan

                              // Trailing Custom (Teks Ubah dan Hapus)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Tombol Teks: Ubah
                                  InkWell(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddAddressScreen(data: a),
                                        ),
                                      );
                                      if (result == true) loadData();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 4.0),
                                      child: Text(
                                        "Ubah",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Garis Pemisah (Divider)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "|",
                                      style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 14),
                                    ),
                                  ),

                                  // Tombol Teks: Hapus
                                  InkWell(
                                    onTap: () async {
                                      await ProfileService.deleteAddress(
                                          a['id']);
                                      loadData();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 4.0),
                                      child: Text(
                                        "Hapus",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[500],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // --- BARIS BAWAH: Detail Alamat Lengkap ---
                          Padding(
                            // Padding kiri (left) dihapus karena radio button sudah hilang,
                            // diganti dengan jarak atas (top) agar tidak menempel dengan judul
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              a['complete_address'] ?? 'Alamat tidak lengkap',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: 10),

                // Tombol "Tambah Alamat" Bergaya Navigasi Modern (seperti referensi 'Personal Detail')
                InkWell(
                  onTap: () async {
                    // Logika asli tombol 'Tambah Alamat' dipertahankan
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddAddressScreen()),
                    );

                    if (result == true) {
                      loadData(); // 🔥 refresh list alamat
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[100], // Warna abu-abu muda seperti referensi
                      borderRadius: _cardBorderRadius,
                      boxShadow: _cardShadow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.add, color: Colors.grey[700], size: 20),
                            SizedBox(width: 12),
                            Text(
                              "Tambah Alamat",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.grey[500], size: 16),
                      ],
                    ),
                  ),
                ),
                // 💡 INI TOMBOL LOGOUT BARU
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      "Keluar Akun",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red[50], // Latar belakang merah sangat muda
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(color: Colors.red[200]!),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),

            // Tombol Logout di pojok kanan bawah (seperti referensi)
          ),
        ],
      ),
    );
  }
}
