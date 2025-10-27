import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    try {
      double opticsTotal = 0.0;
      double repairingTotal = 0.0;
      List<Map<String, dynamic>> sales = [];

      // 🔹 Fetch optics (customers)
      final opticsSnapshot =
      await FirebaseFirestore.instance.collection('customers').get();
      for (var doc in opticsSnapshot.docs) {
        final data = doc.data();
        final amount = (data['total'] ?? 0).toDouble();
        opticsTotal += amount;
        sales.add({
          'name': data['name'] ?? 'Unknown',
          'total': amount,
          'type': 'Prescription',
          'date': data['date'] ?? '', // optional
        });
      }

      // 🔹 Fetch repairing sales
      final repairingSnapshot =
      await FirebaseFirestore.instance.collection('repairing_customers').get();
      for (var doc in repairingSnapshot.docs) {
        final data = doc.data();
        final amount = (data['total'] ?? 0).toDouble();
        repairingTotal += amount;
        sales.add({
          'name': data['name'] ?? 'Unknown',
          'total': amount,
          'type': 'Repairing',
          'date': data['date'] ?? '',
        });
      }

      // Optional: sort by date if you store timestamps
      sales.sort((a, b) {
        final da = a['date']?.toString() ?? '';
        final db = b['date']?.toString() ?? '';
        return db.compareTo(da);
      });

      setState(() {
        opticsSales = opticsTotal;
        repairingSales = repairingTotal;
        totalSales = opticsSales + repairingSales + otherSales;
        allSales = sales;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching sales: $e");
      setState(() => isLoading = false);
    }
  }

  String formatCurrency(double value) {
    return "PKR ${value.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Text(
          "Sales Record",
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Total Sales Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Text("Total Sales",
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 16)),
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

            // 🔹 Sales Breakdown Cards
            _buildSalesCard("Prescription Sales", opticsSales),
            _buildSalesCard("Repairing Sales", repairingSales),
            _buildSalesCard("Other Sales", otherSales),

            const SizedBox(height: 25),

            // 🔹 Filters (UI only)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDropdown("All Time"),
                _buildDropdown("All Sales"),
              ],
            ),

            const SizedBox(height: 25),

            // 🔹 Sales List
            if (allSales.isEmpty)
              Text(
                "No sales data available.",
                style: GoogleFonts.poppins(
                    color: Colors.grey, fontSize: 15),
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
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        sale['type'],
                        style: GoogleFonts.poppins(
                            color: Colors.grey[600], fontSize: 13),
                      ),
                      trailing: Text(
                        "PKR ${sale['total'].toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),

      // 🔹 Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
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
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 5),
          Text(
            "PKR: ${value.toStringAsFixed(2)}",
            style: GoogleFonts.poppins(
              color: const Color(0xFFD32F2F),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(text, style: GoogleFonts.poppins(fontSize: 14)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
