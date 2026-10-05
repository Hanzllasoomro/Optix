import 'package:alioptical/pages/addRepairingCustomerScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servers/auth/auth_service.dart';
import './customerSearchScreen.dart';
import './myShopScreen.dart';
import './addCustomerScreen.dart';
import 'SalesRecordScreen.dart';
import 'expenseScreen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  void logout() {
    AuthService().signOut();
  }

  Future<String> _getShopName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "Shop";

    final data = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

    return data.exists ? data["shopName"] ?? "Shop" : "Shop";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ---------------- HEADER ----------------
                FutureBuilder<String>(
                  future: _getShopName(),
                  builder: (context, snapshot) {
                    final shopName = snapshot.data ?? "Loading...";

                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: isWide ? 60 : 50,
                        horizontal: isWide ? 40 : 20,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFBA68C8), Color(0xFFBA68C8)],
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
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.store_mall_directory_rounded, color: Colors.white, size: 55),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            shopName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: isWide ? 28 : 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 35),

                // ---------------- QUICK BUTTONS (Wrap) ----------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _quickButton(
                        icon: Icons.person_add_alt_1_rounded,
                        label: "Add Customer",
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AddCustomerScreen())),
                      ),
                      _quickButton(
                        icon: Icons.search_rounded,
                        label: "Search Customer",
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const CustomerSearchScreen())),
                      ),
                      _quickButton(
                        icon: Icons.build_rounded,
                        label: "Repairing Customer",
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => AddRepairingCustomerScreen())),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ---------------- SECTION TITLE ----------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBA68C8).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "More with Optix",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF7B1FA2),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ---------------- GRID SECTION ----------------
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700), // wider for web
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 5)),
                        ],
                      ),

                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double maxWidth = constraints.maxWidth;

                          // FORCE 4 items in one row on web
                          int itemsPerRow;
                          if (maxWidth >= 600) {
                            itemsPerRow = 4; // web/tablet → always 4 in one row
                          } else {
                            itemsPerRow = (maxWidth / 150).floor();
                            if (itemsPerRow < 2) itemsPerRow = 2; // mobile minimum 2
                          }

                          final features = [
                            {
                              "icon": Icons.store_mall_directory_rounded,
                              "label": "My Shop",
                              "onTap": ()  async {
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
                            },
                            {
                              "icon": Icons.bar_chart_rounded,
                              "label": "Sales",
                              "onTap": () =>
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesRecordScreen())),
                            },
                            {
                              "icon": Icons.receipt_long,
                              "label": "Expense",
                              "onTap": () =>
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen())),
                            },
                            {
                              "icon": Icons.exit_to_app_rounded,
                              "label": "Logout",
                              "onTap": logout,
                            },
                          ];

                          int totalItems = features.length;
                          int rows = (totalItems / itemsPerRow).ceil();
                          List<Widget> rowsList = [];

                          for (int row = 0; row < rows; row++) {
                            int start = row * itemsPerRow;
                            int end = (start + itemsPerRow).clamp(0, totalItems);

                            List<Widget> rowItems = [];

                            for (int i = start; i < end; i++) {
                              final f = features[i];
                              rowItems.add(
                                Expanded(
                                  child: _miniFeature(
                                    icon: f["icon"] as IconData,
                                    label: f["label"] as String,
                                    onTap: f["onTap"] as VoidCallback,
                                  ),
                                ),
                              );
                            }

                            // center-align + fill empty slots on last row
                            int emptySlots = itemsPerRow - rowItems.length;
                            for (int i = 0; i < emptySlots; i++) {
                              rowItems.add(const Expanded(child: SizedBox()));
                            }

                            rowsList.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: rowItems,
                                ),
                              ),
                            );
                          }

                          return Column(children: rowsList);
                        },
                      ),
                    ),
                  ),
                ),



                const SizedBox(height: 30),

                Text(
                  "Developed by Kabeer with 💜",
                  style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 14),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- QUICK BUTTON ----------------
  Widget _quickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFBA68C8).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBA68C8).withOpacity(0.25)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,   // prevents overflow
          children: [
            Icon(icon, size: 32, color: const Color(0xFF8E24AA)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- MINI FEATURE CARD ----------------
  Widget _miniFeature({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,   // <--- THIS REMOVES 100% OVERFLOWS
        children: [
          Icon(icon, size: 30, color: const Color(0xFF8E24AA)),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
