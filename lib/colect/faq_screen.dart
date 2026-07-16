import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Pusat Bantuan (FAQ)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Pertanyaan yang Sering Diajukan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          _buildFaqItem(
            question: "Berapa lama proses pembuatan kacamata?",
            answer: "Untuk lensa standar, proses perakitan memakan waktu 1-2 hari kerja. Lensa khusus (seperti Progresif atau Silinder tinggi) bisa memakan waktu 3-5 hari kerja.",
          ),
          _buildFaqItem(
            question: "Apakah saya bisa menggunakan resep dokter?",
            answer: "Tentu saja! Anda bisa mengunggah foto kartu resep dokter atau hasil pemeriksaan klinik mata saat menambahkan kacamata ke keranjang.",
          ),
          _buildFaqItem(
            question: "Bagaimana kebijakan garansi di Optik Alhazen?",
            answer: "Kami memberikan garansi lapisan lensa (mengelupas) selama 6 bulan dan garansi setel frame gratis seumur hidup. Sertakan nomor pesanan Anda saat klaim.",
          ),
          _buildFaqItem(
            question: "Apakah melayani pengiriman ke luar kota?",
            answer: "Ya, kami melayani pengiriman ke seluruh Indonesia menggunakan kurir terpercaya yang dipacking dengan kotak keras (hardcase) dan bubble wrap super tebal.",
          ),
        ],
      ),
    );
  }

  // Widget bantuan untuk membuat kotak pertanyaan yang bisa dilipat
  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2D2D2D)),
        ),
        iconColor: const Color(0xFF3F51B5),
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            answer,
            style: TextStyle(height: 1.5, color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}