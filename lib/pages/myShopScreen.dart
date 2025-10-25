import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './editShopScreen.dart';

class MyShopScreen extends StatelessWidget {
  final String shopName;
  final String email;
  final String contact;
  final String address;
  final int totalCustomers;
  final int opticsCustomers;
  final int repairingCustomers;
  final String subscriptionStatus;
  final int daysLeft;

  const MyShopScreen({
    Key? key,
    required this.shopName,
    required this.email,
    required this.contact,
    required this.address,
    required this.totalCustomers,
    required this.opticsCustomers,
    required this.repairingCustomers,
    required this.subscriptionStatus,
    required this.daysLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Text(
          'My Shop',
          style: GoogleFonts.poppins(
            fontSize: isWide ? 24 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 40 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.store, color: const Color(0xFFD32F2F), size: isWide ? 90 : 70),
            const SizedBox(height: 10),
            Text(
              shopName,
              style: GoogleFonts.poppins(
                fontSize: isWide ? 26 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text("Contact: $contact", style: GoogleFonts.poppins(fontSize: 14)),
            Text("Address: $address", style: GoogleFonts.poppins(fontSize: 14)),
            Text("Email: $email", style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 20),

            // 🔹 Grid Cards
            GridView.count(
              crossAxisCount: isWide ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _buildInfoCard("Total Customers", totalCustomers.toString()),
                _buildInfoCard("Optics Customers", opticsCustomers.toString()),
                _buildInfoCard("Repairing Customers", repairingCustomers.toString()),
              ],
            ),
            const SizedBox(height: 20),

            // 🔹 Subscription
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Subscription Status",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(
                    "$subscriptionStatus - $daysLeft days left",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: subscriptionStatus == "Active"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  context,
                  label: "Edit Details ✏️",
                  color: const Color(0xFFD32F2F),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditShopScreen(),
                      ),
                    );
                  },
                ),
                _buildButton(
                  context,
                  label: "Get 35% Discount 🎁",
                  color: const Color(0xFFB71C1C),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Offer applied successfully!"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade200.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label,
        required Color color,
        required VoidCallback onTap}) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
