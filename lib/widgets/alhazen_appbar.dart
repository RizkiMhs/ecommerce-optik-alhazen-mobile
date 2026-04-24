import 'package:flutter/material.dart';
import 'package:optik_alhazen_app/screens/cart_screen.dart';
// import '../screens/cart_screen.dart';

class AlhazenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCart;

  const AlhazenAppBar({Key? key, required this.title, this.showCart = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Color(0xFF3F51B5),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (showCart)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Badge(
                label: Text(
                    '!'), // Nanti bisa dihubungkan ke Stream/Provider untuk angka real
                child: Icon(Icons.shopping_cart_outlined),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
