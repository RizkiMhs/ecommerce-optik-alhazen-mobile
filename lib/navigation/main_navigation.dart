import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/order_screen.dart'; // 💡 Tambahkan ini

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Color(0xFF3F51B5),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, "Beranda", 0),
              _navItem(Icons.receipt_long, "Pesanan", 1),
              _navItem(Icons.person, "Profil", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Color(0xFF3F51B5) : Colors.white,
            ),
            if (isActive) ...[
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF3F51B5),
                  fontWeight: FontWeight.bold,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
