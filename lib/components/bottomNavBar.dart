import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pages/customerSearchScreen.dart';
import '../../pages/myShopScreen.dart';
// import '../pages/repairingScreen.dart'; // Add when ready

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Avoid reloading same screen

    switch (index) {
      case 0:
      // Repairing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Repairing Screen Coming Soon")),
        );
        break;
      case 1:
      // Search
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerSearchScreen()),
        );
        break;
      case 2:
      // Shop
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MyShopScreen(
              shopName: "Tariq Eye Corner",
              email: "tariqopticals@gmail.com",
              contact: "03126017600",
              address: "Main Saddar, Karachi",
              subscriptionStatus: "Active",
              daysLeft: 9, // mock data for now
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.build,
              label: "Repairing",
              active: currentIndex == 0,
              onTap: () => _onItemTapped(context, 0),
            ),
            const SizedBox(width: 48), // Space for FAB
            _BottomNavItem(
              icon: Icons.search,
              label: "Search",
              active: currentIndex == 1,
              onTap: () => _onItemTapped(context, 1),
            ),
            _BottomNavItem(
              icon: Icons.storefront,
              label: "Shop",
              active: currentIndex == 2,
              onTap: () => _onItemTapped(context, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.red.shade700 : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
