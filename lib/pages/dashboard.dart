import 'package:alioptical/servers/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './customerSearchScreen.dart';
import './myShopScreen.dart';
import './addCustomerScreen.dart';
import 'SalesRecordScreen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  void logout() {
    final _authService = AuthService();
    _authService.signOut();
  }

  // 🔹 Function to get shop name of current logged-in user
  Future<String> _getShopName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Shop";

    final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    if (doc.exists && doc.data()?['shopName'] != null) {
      return doc['shopName'];
    }
    return "Shop";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      body: SafeArea(
        child: Column(
          children: [
            // 🔴 Header with dynamic shop name
            FutureBuilder<String>(
              future: _getShopName(),
              builder: (context, snapshot) {
                String shopName = "Loading...";
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    shopName = snapshot.data!;
                  } else {
                    shopName = "Shop";
                  }
                }

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isWide ? 50 : 40,
                    horizontal: isWide ? 40 : 20,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),

                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.store,
                        color: Colors.white,
                        size: isWide ? 80 : 60,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        shopName,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isWide ? 28 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

      
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  double aspectRatio;

                  if (constraints.maxWidth >= 1000) {
                    crossAxisCount = 4;
                    aspectRatio = 1.2;
                  } else if (constraints.maxWidth >= 600) {
                    crossAxisCount = 3;
                    aspectRatio = 1.0;
                  } else {
                    crossAxisCount = 2;
                    aspectRatio = 1.0;
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 60 : 16,
                      vertical: 10,
                    ),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: aspectRatio,
                      children: [
                        _DashboardButton(
                          icon: Icons.person_add,
                          label: "Add Customer",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddCustomerScreen(),
                              ),
                            );
                          },
           isWide: isWide,
                        ),
                        _DashboardButton(
                          icon: Icons.search,
                          label: "Search Customer",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerSearchScreen(),
                              ),
                            );
                          },
                          isWide: isWide,
                        ),
                        _DashboardButton(
                          icon: Icons.build,
                          label: "Add Repairing Customer",
                          onTap: () {},
                          isWide: isWide,
                        ),
                        _DashboardButton(
                          icon: Icons.bar_chart,
                          label: "Sales Record",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SalesRecordScreen()),
                            );
                          },
                          isWide: isWide,
                        ),

                        _DashboardButton(
                          icon: Icons.storefront,
                          label: "My Shop",
                          onTap: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
                              if (doc.exists) {
                                final data = doc.data()!;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyShopScreen(
                                      shopName: data['shopName'] ?? 'Shop',
                                      email: data['email'] ?? 'N/A',
                                      contact: data['contactNumber'] ?? 'N/A',
                                      address: data['address'] ?? 'N/A',
                                      subscriptionStatus: data['subscriptionStatus'] ?? 'Inactive',
                                      daysLeft: data['daysLeft'] ?? 0,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          isWide: isWide,
                        ),
                        _DashboardButton(
                          icon: Icons.power_settings_new,
                          label: "Logout",
                          onTap: logout,
                          isWide: isWide,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isWide;

  const _DashboardButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isWide,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.shade200.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isWide ? 60 : 40,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: isWide ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
