import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'addCustomerScreen.dart';

class SalesRecordScreen extends StatefulWidget {
  const SalesRecordScreen({Key? key}) : super(key: key);

  @override
  State<SalesRecordScreen> createState() => _SalesRecordScreenState();
}

class _SalesRecordScreenState extends State<SalesRecordScreen> {
  double totalSales = 0.0;
  double opticsSales = 0.0;
  double repairingSales = 0.0;
  double otherSales = 0.0;
  bool isLoading = true;

  List<Map<String, dynamic>> allSales = [];

  // Dropdown selections
  String selectedTimeFilter = "All Time";
  String selectedTypeFilter = "All Sales";

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => isLoading = false);
        return;
      }

      double opticsTotal = 0.0;
      double repairingTotal = 0.0;
      List<Map<String, dynamic>> sales = [];

      final now = DateTime.now();

      bool isInTimeFilter(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return false;
        final date = DateTime.tryParse(dateStr);
        if (date == null) return false;

        switch (selectedTimeFilter) {
          case "This Week":
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            final weekEnd = weekStart.add(const Duration(days: 6));
            return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                date.isBefore(weekEnd.add(const Duration(days: 1)));
          case "This Month":
            return date.year == now.year && date.month == now.month;
          case "This Year":
            return date.year == now.year;
          default:
            return true; // All Time
        }
      }

      // 🔹 Fetch from current user's "customers"
      final opticsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('customers')
          .get();

      for (var doc in opticsSnapshot.docs) {
        final data = doc.data();
        final amount = (data['total'] ?? 0).toDouble();
        final dateStr = data['date'] ?? '';
        if (!isInTimeFilter(dateStr)) continue;

        opticsTotal += amount;
        sales.add({
          'name': data['name'] ?? 'Unknown',
          'total': amount,
          'type': 'Prescription',
          'date': dateStr,
        });
      }

      // 🔹 Fetch from current user's "repairing_customers"
      final repairingSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('repairing_customers')
          .get();

      for (var doc in repairingSnapshot.docs) {
        final data = doc.data();
        final amount = (data['total'] ?? 0).toDouble();
        final dateStr = data['date'] ?? '';
        if (!isInTimeFilter(dateStr)) continue;

        repairingTotal += amount;
        sales.add({
          'name': data['name'] ?? 'Unknown',
          'total': amount,
          'type': 'Repairing',
          'date': dateStr,
        });
      }

      // 🔹 Sort by date descending
      sales.sort((a, b) {
        final da = a['date'] ?? '';
        final db = b['date'] ?? '';
        return db.compareTo(da);
      });

      // 🔹 Apply Type Filter
      if (selectedTypeFilter != "All Sales") {
        sales = sales.where((s) => s['type'] == selectedTypeFilter).toList();
        if (selectedTypeFilter == "Prescription") repairingTotal = 0.0;
        if (selectedTypeFilter == "Repairing") opticsTotal = 0.0;
        if (selectedTypeFilter == "Other") {
          opticsTotal = 0.0;
          repairingTotal = 0.0;
        }
      }

      setState(() {
        opticsSales = opticsTotal;
        repairingSales = repairingTotal;
        totalSales = opticsSales + repairingSales + otherSales;
        allSales = sales;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching sales: $e");
      setState(() => isLoading = false);
    }
  }



  String formatCurrency(double value) => "PKR ${value.toStringAsFixed(2)}";

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBA68C8),
        elevation: 0,
        title: Text(
          "Sales Record",
          style: GoogleFonts.poppins(
            fontSize: isWide ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total Sales
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBA68C8), Color(0xFFBA68C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Text("Total Sales",
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(totalSales),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sales Breakdown
            _buildSalesCard("Prescription Sales", opticsSales),
            _buildSalesCard("Repairing Sales", repairingSales),
            _buildSalesCard("Other Sales", otherSales),
            const SizedBox(height: 25),

            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeDropdown(),
                _buildTypeDropdown(),
              ],
            ),
            const SizedBox(height: 25),

            // Sales List
            if (allSales.isEmpty)
              Text(
                "No sales data available.",
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allSales.length,
                itemBuilder: (context, index) {
                  final sale = allSales[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: sale['type'] == 'Repairing'
                            ? Colors.orange
                            : Colors.green,
                        child: Icon(
                          sale['type'] == 'Repairing'
                              ? Icons.build
                              : Icons.remove_red_eye,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        sale['name'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        sale['type'],
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                      ),
                      trailing: Text(
                        "PKR ${sale['total'].toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFBA68C8),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFBA68C8),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCustomerScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSalesCard(String title, double value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 5),
          Text(
            "PKR: ${value.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              color: const Color(0xFFBA68C8),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDropdown() {
    final options = ["All Time", "This Week", "This Month", "This Year"];
    return DropdownButton<String>(
      value: selectedTimeFilter,
      items: options.map((e) => DropdownMenuItem(
        value: e,
        child: Text(e, style: GoogleFonts.poppins()),
      )).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedTimeFilter = value;
            isLoading = true;
          });
          _fetchSalesData();
        }
      },
    );
  }

  Widget _buildTypeDropdown() {
    final options = ["All Sales", "Prescription", "Repairing", "Other"];
    return DropdownButton<String>(
      value: selectedTypeFilter,
      items: options.map((e) => DropdownMenuItem(
        value: e,
        child: Text(e, style: GoogleFonts.poppins()),
      )).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedTypeFilter = value;
            isLoading = true;
          });
          _fetchSalesData();
        }
      },
    );
  }
}
