import 'package:flutter/material.dart';
import 'dart:async'; // Untuk Timer Polling
import 'package:intl/intl.dart'; // Untuk format jam
import '../services/consultation_service.dart'; // 💡 Import service API yang baru dibuat
import '../widgets/alhazen_appbar.dart';

class ConsultationChatScreen extends StatefulWidget {
  const ConsultationChatScreen({Key? key}) : super(key: key);

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  Timer? _timer;
  List<dynamic> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 1. Tarik data pertama kali saat layar dibuka
    _fetchMessages();

    // 2. 💡 JALANKAN HTTP POLLING: Tarik data dari API setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchMessages(isBackgroundRefresh: true);
    });
  }

  @override
  void dispose() {
    // 💡 SANGAT PENTING: Matikan timer saat user berpindah tab/layar agar tidak boros baterai
    _timer?.cancel(); 
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Tarik data dari Laravel
  Future<void> _fetchMessages({bool isBackgroundRefresh = false}) async {
    final data = await ConsultationService.getMessages();
    
    // Cegah error setState jika user sudah pindah layar
    if (!mounted) return; 

    // Cek apakah jumlah pesannya bertambah
    bool isNewMessageArrived = data.length > messages.length;

    setState(() {
      messages = data;
      if (!isBackgroundRefresh) isLoading = false;
    });

    // Jika ada pesan baru masuk, otomatis gulir layar ke paling bawah
    if (isNewMessageArrived) {
      _scrollToBottom();
    }
  }

  // Kirim Pesan ke Laravel
  void _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear(); // Kosongkan textfield
    _scrollToBottom(); // Gulir ke bawah

    // Panggil fungsi POST API
    bool success = await ConsultationService.sendMessage(text);
    
    if (success) {
      // Jika berhasil, panggil data terbaru agar langsung muncul di layar
      _fetchMessages();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan. Periksa koneksi Anda.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Fungsi mengubah waktu bawaan Laravel (Y-m-d H:i:s) menjadi format Jam:Menit (10:30)
  String _formatTime(String? dateString) {
    if (dateString == null) return "";
    try {
      DateTime parsedDate = DateTime.parse(dateString).toLocal();
      return DateFormat('HH:mm').format(parsedDate);
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      // 💡 Kita hilangkan tombol "Back" karena layarnya sekarang menempel di BottomNavigation
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, 
        title: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE8EAF6),
                  child: Icon(Icons.support_agent, color: Color(0xFF3F51B5)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Optician Alhazen", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Konsultasi Online", style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- AREA BALON CHAT ---
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3F51B5)))
                : messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text("Belum ada pesan.\nKirim keluhan mata Anda sekarang!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500], height: 1.5)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // Bottom padding extra for keyboard
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          // Cek apakah pengirimnya admin (bisa boolean atau angka 1 dari MySQL)
                          final isAdmin = msg['is_admin'] == true || msg['is_admin'] == 1;
                          final time = _formatTime(msg['created_at']);

                          return _buildChatBubble(msg['message'], isAdmin, time);
                        },
                      ),
          ),

          // --- AREA KETIK PESAN ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Tulis keluhan Anda...",
                          border: InputBorder.none,
                        ),
                        maxLines: null, 
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3F51B5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DESAIN BALON CHAT
  Widget _buildChatBubble(String message, bool isAdmin, String time) {
    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, 
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.white : const Color(0xFF3F51B5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 0 : 16), 
            bottomRight: Radius.circular(isAdmin ? 16 : 0), 
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isAdmin ? Colors.black87 : Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isAdmin ? Colors.grey[400] : Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}