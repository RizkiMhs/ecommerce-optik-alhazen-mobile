// 


import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class AddAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const AddAddressScreen({Key? key, this.data}) : super(key: key);

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _label = TextEditingController();
  final _recipient = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _postal = TextEditingController();

  // 💡 PERUBAHAN 1: City tidak lagi pakai TextEditingController
  String? _selectedCityId;
  String? _selectedCityName;

  bool _isMain = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.data != null) {
      _label.text = widget.data!['label'] ?? '';
      _recipient.text = widget.data!['recipient_name'] ?? '';
      _phone.text = widget.data!['phone'] ?? '';
      _address.text = widget.data!['complete_address'] ?? '';
      _postal.text = widget.data!['postal_code'] ?? '';
      
      // Mengisi data kota jika sedang edit
      _selectedCityId = widget.data!['city_id']?.toString();
      // Idealnya kita menyimpan nama kota juga di DB agar bisa ditampilkan saat edit,
      // Untuk sementara kita tampilkan ID-nya jika namanya belum ada
      _selectedCityName = widget.data!['city_name'] ?? "Kota Terpilih (ID: $_selectedCityId)"; 
      
      _isMain = widget.data!['is_main'] == 1;
    }
  }

  void _submit() async {
    // 💡 Validasi juga memastikan kota sudah dipilih
    if (_label.text.isEmpty ||
        _recipient.text.isEmpty ||
        _phone.text.isEmpty ||
        _address.text.isEmpty ||
        _selectedCityId == null || 
        _postal.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Semua field wajib diisi, termasuk Kota!"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    Map<String, dynamic> body = {
      "label": _label.text,
      "recipient_name": _recipient.text,
      "phone": _phone.text,
      "complete_address": _address.text,
      "city_id": _selectedCityId, // 💡 Menggunakan ID yang dipilih
      "postal_code": _postal.text,
      "is_main": _isMain
    };

    bool success;

    if (widget.data != null) {
      success = await ProfileService.updateAddress(widget.data!['id'], body);
    } else {
      success = await ProfileService.addAddress(body);
    }

    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan alamat"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // 💡 PERUBAHAN 2: Fungsi untuk menampilkan Pop-up Pencarian Kota
  void _showCityBottomSheet() {
    List<dynamic> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // StatefulBuilder digunakan agar kita bisa melakukan setState khusus di dalam Pop-up ini saja
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 20),
                  const Text("Pilih Kota / Kabupaten", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // 💡 KOTAK PENCARIAN REAL-TIME
                  TextField(
                    autofocus: true, // Keyboard otomatis muncul
                    decoration: InputDecoration(
                      hintText: "Ketik minimal 3 huruf (misal: lhok)...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onChanged: (value) async {
                      // Hanya mencari jika pengguna sudah mengetik minimal 3 huruf agar API tidak kelebihan beban
                      if (value.length >= 3) {
                        setModalState(() => isSearching = true);
                        
                        // Menembak API Laravel
                        final results = await ProfileService.searchCities(value);
                        
                        print("Jumlah data yang diterima UI: ${results.length} item");
                        setModalState(() {
                          searchResults = results;
                          isSearching = false;
                        });
                      } else {
                        setModalState(() {
                          searchResults = []; // Kosongkan jika huruf kurang dari 3
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // 💡 HASIL PENCARIAN
                  Expanded(
                    child: isSearching
                        ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                        : searchResults.isEmpty
                            ? Center(
                                child: Text(
                                  "Ketik nama kota Anda di atas",
                                  style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                                ),
                              )
                            : ListView.builder(
                                itemCount: searchResults.length,
                                itemBuilder: (context, index) {
                                  final city = searchResults[index];
                                  return ListTile(
                                    title: Text(city["name"]),
                                    trailing: const Icon(Icons.check_circle_outline, size: 20, color: Colors.blueAccent),
                                    onTap: () {
                                      // Jika diklik, simpan data dan tutup pop-up
                                      setState(() {
                                        _selectedCityId = city["id"].toString();
                                        _selectedCityName = city["name"];
                                      });
                                      Navigator.pop(context);
                                    },
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
    final String pageTitle = widget.data != null ? "Edit Alamat" : "Tambah Alamat";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          pageTitle,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informasi Alamat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 16),

            _input(_label, "Label (Misal: Rumah, Kantor)", icon: Icons.label_outline),
            _input(_recipient, "Nama Penerima", icon: Icons.person_outline),
            _input(_phone, "No HP", icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            
            // 💡 PERUBAHAN 3: Widget Pemilihan Kota
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: _showCityBottomSheet, // Panggil pop-up saat ditekan
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Kota / Kabupaten",
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Icon(Icons.location_city_outlined, color: Colors.blue[600], size: 22),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCityName ?? "Pilih Kota Anda",
                        style: TextStyle(
                          fontSize: 15,
                          color: _selectedCityName != null ? Colors.grey[900] : Colors.grey[500],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),

            _input(_address, "Alamat Lengkap", maxLines: 3, icon: Icons.location_on_outlined),
            _input(_postal, "Kode Pos", icon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SwitchListTile(
                title: Text("Jadikan alamat utama", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[800])),
                activeColor: Colors.blue[600],
                value: _isMain,
                onChanged: (val) => setState(() => _isMain = val),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 32),

            _loading
                ? Center(child: CircularProgressIndicator(color: Colors.blue[800]))
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text("Simpan Alamat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    int maxLines = 1,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, color: Colors.grey[900]),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Icon(icon, color: Colors.blue[600], size: 22),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          alignLabelWithHint: maxLines > 1,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
        ),
      ),
    );
  }
}