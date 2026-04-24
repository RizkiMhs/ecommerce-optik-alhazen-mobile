import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../navigation/main_navigation.dart'; // Sesuaikan jika import navigasi Anda berbeda

class PaymentScreen extends StatefulWidget {
  final String snapToken;

  const PaymentScreen({Key? key, required this.snapToken}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // URL Snap Midtrans Sandbox
    final String paymentUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/${widget.snapToken}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          // 💡 LOGIKA CERDAS: Mendeteksi jika pembayaran selesai
          onNavigationRequest: (NavigationRequest request) {
            // Midtrans biasanya melempar URL yang mengandung kata "transaction_status" 
            // atau kembali ke base URL Anda jika pembayaran sukses/pending.
            // Anda bisa menangkapnya di sini untuk otomatis menutup halaman.
            if (request.url.contains('transaction_status=settlement') || 
                request.url.contains('transaction_status=capture') ||
                request.url.contains('status_code=200')) {
               
               // Tutup halaman webview dan kembali ke beranda
               Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MainNavigation()), 
                  (route) => false
               );
               return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pembayaran", style: TextStyle(color: Colors.black87, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Jika user menekan tombol silang/tutup
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Batalkan Pembayaran?"),
                content: const Text("Pesanan Anda sudah tersimpan. Anda dapat membayarnya nanti melalui menu Pesanan Saya."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), 
                    child: const Text("Lanjut Bayar")
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MainNavigation()), 
                        (route) => false
                      ); // Kembali ke Beranda
                    }, 
                    child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red))
                  ),
                ],
              )
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF3F51B5)),
            ),
        ],
      ),
    );
  }
}