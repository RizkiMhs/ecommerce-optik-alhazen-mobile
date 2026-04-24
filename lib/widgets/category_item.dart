import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryItem({
    Key? key,
    required this.label,
    this.isActive = false, // Status apakah kategori sedang dipilih
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.only(right: 10), // Jarak antar kategori
        decoration: BoxDecoration(
          // Jika aktif warna hitam (seperti referensi), jika tidak putih/abu-abu halus
          color: isActive ? Color(0xFF3F51B5) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
