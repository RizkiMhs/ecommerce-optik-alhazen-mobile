import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustumerCareScreen extends StatefulWidget {
  const CustumerCareScreen({super.key});

  @override
  State<CustumerCareScreen> createState() => _CustumerCareScreenState();
}

class _CustumerCareScreenState extends State<CustumerCareScreen> {
  // 💡 1. Tambahkan controller untuk membaca inputan teks dari user
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    // Pastikan controller dihapus dari memori saat halaman ditutup
    _messageController.dispose();
    super.dispose();
  }

  // Fungsi untuk membuka WhatsApp
  Future<void> _launchWhatsApp() async {
    const String phoneNumber = '6282352306497';
    
    // 💡 2. Ambil teks dari inputan. Jika kosong, gunakan pesan default.
    String message = _messageController.text.trim();
    if (message.isEmpty) {
      message = 'Halo Admin Optik Alhazen, saya butuh bantuan dari Customer Care.';
    }
    
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showErrorSnackBar();
      }
    } catch (e) {
      _showErrorSnackBar();
    }
  }

  void _showErrorSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstal.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Background sedikit abu-abu agar form menonjol
      appBar: AppBar(
        title: const Text("Customer Care", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // 💡 3. Menggunakan SingleChildScrollView agar tidak error saat keyboard muncul
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER ILLUSTRATION ---
            const SizedBox(height: 20),
            const Icon(
              Icons.support_agent_rounded,
              size: 100,
              color: Color(0xFF3F51B5),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ada yang bisa kami bantu?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tuliskan pertanyaan atau keluhan Anda di bawah ini, admin kami akan membalas melalui WhatsApp.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // --- INPUT WIDGET ---
            _buildMessageInput(),

            const SizedBox(height: 24),

            // --- BUTTON WIDGET ---
            ElevatedButton.icon(
              onPressed: _launchWhatsApp,
              icon: const Icon(Icons.chat_rounded),
              label: const Text(
                "Kirim via WhatsApp",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 4. Widget khusus untuk Form Input agar kode build() tetap bersih dan rapi
  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _messageController,
        maxLines: 5, // Membuat kotak input lebih tinggi seperti textarea
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "Contoh: Halo min, pesanan saya nomor ORD-123 belum sampai...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, // Menghilangkan garis hitam bawaan
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}