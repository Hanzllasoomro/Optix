import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './editShopScreen.dart';
import 'addCustomerScreen.dart';

class MyShopScreen extends StatefulWidget {
  final String shopName;
  final String email;
  final String contact;
  final String address;
  final String subscriptionStatus;
  final int daysLeft;

  const MyShopScreen({
    Key? key,
    required this.shopName,
    required this.email,
    required this.contact,
    required this.address,
    required this.subscriptionStatus,
    required this.daysLeft,
  }) : super(key: key);

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  int totalCustomers = 0;
  int opticsCustomers = 0;
  int repairingCustomers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomerCounts();
  }

  Future<void> _fetchCustomerCounts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in");
        setState(() => isLoading = false);
        return;
      }

      final userRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid);

      // 🔹 Fetch optics (customers) for current user
      final opticsSnapshot = await userRef.collection('customers').get();
      opticsCustomers = opticsSnapshot.size;

      // 🔹 Fetch repairing customers for current user
      final repairingSnapshot = await userRef.collection('repairing_customers').get();
      repairingCustomers = repairingSnapshot.size;

      // 🔹 Calculate total
      totalCustomers = opticsCustomers + repairingCustomers;

      setState(() => isLoading = false);
    } catch (e) {
      print("❌ Error fetching customer counts: $e");
      setState(() => isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBA68C8),
        elevation: 0,
        title: Text(
          'My Shop',
          style: GoogleFonts.poppins(
            fontSize: isWide ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.white
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFBA68C8)))
          : SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 40 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.store,
                color: const Color(0xFFBA68C8), size: isWide ? 90 : 70),
            const SizedBox(height: 10),
            Text(
              widget.shopName,
              style: GoogleFonts.poppins(
                fontSize: isWide ? 26 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text("Contact: ${widget.contact}",
                style: GoogleFonts.poppins(fontSize: 14)),
            Text("Address: ${widget.address}",
                style: GoogleFonts.poppins(fontSize: 14)),
            Text("Email: ${widget.email}",
                style: GoogleFonts.poppins(fontSize: 14)),
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
                _buildInfoCard("Prescription Customers", opticsCustomers.toString()),
                _buildInfoCard(
                    "Repairing Customers", repairingCustomers.toString()),
              ],
            ),



            const SizedBox(height: 30),

            // 🔹 Centered Edit Button
            Center(
              child: SizedBox(
                width: isWide ? 250 : double.infinity,
                child: _buildButton(
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFBA68C8),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCustomerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBA68C8), Color(0xFFBA68C8)],
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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFBA68C8),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
