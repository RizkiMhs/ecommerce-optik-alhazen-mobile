import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io'; // 💡 Import untuk File gambar
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // 💡 Import package Image Picker
import '../services/consultation_service.dart';
import '../config/api_config.dart'; // 💡 Butuh baseUrl untuk me-load gambar
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
  bool isSending = false; // 💡 Menandakan jika gambar/pesan sedang di-upload

  final ImagePicker _picker = ImagePicker(); // 💡 Instance ImagePicker

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!isSending) _fetchMessages(isBackgroundRefresh: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages({bool isBackgroundRefresh = false}) async {
    final data = await ConsultationService.getMessages();
    if (!mounted) return;

    bool isNewMessageArrived = data.length > messages.length;

    setState(() {
      messages = data;
      if (!isBackgroundRefresh) isLoading = false;
    });

    if (isNewMessageArrived) {
      _scrollToBottom();
    }
  }

  // --- 💡 FUNGSI MEMILIH GAMBAR ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Kompres sedikit agar tidak berat
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        // Langsung kirim gambar saat dipilih (tanpa teks)
        _sendMessage(imageFile: imageFile);
      }
    } catch (e) {
      print("Gagal memilih gambar: $e");
    }
  }

  // --- 💡 FUNGSI TAMPILKAN PILIHAN KAMERA/GALERI ---
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Kirim Foto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionBtn(Icons.camera_alt, "Kamera", () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _buildOptionBtn(Icons.photo_library, "Galeri", () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBtn(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: const Color(0xFFE8EAF6), child: Icon(icon, color: const Color(0xFF3F51B5), size: 30)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- 💡 UPDATE: Fungsi kirim mendukung teks & gambar ---
  void _sendMessage({File? imageFile}) async {
    final String text = _messageController.text.trim();

    // Jangan lakukan apa-apa jika teks kosong dan gambar tidak ada
    if (text.isEmpty && imageFile == null) return;

    setState(() { isSending = true; });

    _messageController.clear();
    _scrollToBottom();

    bool success = await ConsultationService.sendMessage(text, imageFile: imageFile);

    setState(() { isSending = false; });

    if (success) {
      _fetchMessages();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan.'), backgroundColor: Colors.red),
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
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isAdmin = msg['is_admin'] == true || msg['is_admin'] == 1;
                          final time = _formatTime(msg['created_at']);

                          // 💡 Parsing image url
                          final String? imageUrl = msg['image'] != null && msg['image'].toString().isNotEmpty
                              ? msg['image']
                              : null;

                          return _buildChatBubble(msg['message'], imageUrl, isAdmin, time);
                        },
                      ),
          ),

          // --- AREA KETIK PESAN & TOMBOL ATTACHMENT ---
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
                  // 💡 Tombol Attachment (Penjepit Kertas)
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: _showImageSourceDialog, // Membuka pilihan Kamera/Galeri
                  ),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 16, right: 8),
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
                    onTap: isSending ? null : () => _sendMessage(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSending ? Colors.grey : const Color(0xFF3F51B5),
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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

  // --- 💡 UPDATE DESAIN BALON CHAT (MENAMPILKAN GAMBAR) ---
  Widget _buildChatBubble(String? message, String? imageUrl, bool isAdmin, String time) {
    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
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

            // 💡 1. Tampilkan Gambar Jika Ada
            if (imageUrl != null)
              Padding(
                padding: EdgeInsets.only(bottom: (message != null && message.isNotEmpty) ? 8.0 : 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    // Asumsikan Laravel menyimpan path relatif seperti 'chat_images/namafile.jpg'
                    '${ApiConfig.baseUrl.replaceAll('/api', '')}/storage/$imageUrl',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        color: Colors.black12,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.red[100],
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.red, size: 40)),
                    ),
                  ),
                ),
              ),

            // 💡 2. Tampilkan Teks Jika Ada
            if (message != null && message.isNotEmpty)
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
