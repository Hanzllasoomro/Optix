import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  String selectedFilter = 'Today';
  double totalExpenses = 0.0;
  bool isLoading = true;
  List<Map<String, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }
  List<Map<String, dynamic>> _applyFilter() {
    DateTime now = DateTime.now();

    return expenses.where((exp) {
      DateTime date = DateTime.tryParse(exp['date'] ?? '') ?? now;

      switch (selectedFilter) {
        case 'Today':
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

        case 'This Week':
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
          return date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
              date.isBefore(endOfWeek.add(const Duration(seconds: 1)));

        case 'This Month':
          return date.year == now.year && date.month == now.month;

        case 'This Year':
          return date.year == now.year;

        default:
          return true;
      }
    }).toList();
  }
  double _calculateFilteredTotal(List<Map<String, dynamic>> filtered) {
    double total = 0;
    for (var exp in filtered) {
      total += exp['amount'] ?? 0;
    }
    return total;
  }


  Future<void> _confirmDelete(String expenseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('expenses')
          .doc(expenseId)
          .delete();

      // ✅ Refresh after deletion
      _fetchExpenses();
    }
  }

  Future<void> _fetchExpenses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('expenses')
          .orderBy('createdAt', descending: true)
          .get();

      double total = 0.0;
      final data = snapshot.docs.map((doc) {
        final d = doc.data();
        total += (d['amount'] ?? 0).toDouble();
        return {
          'id': doc.id, // ✅ store doc id here
          'title': d['title'] ?? 'Untitled Expense',
          'amount': (d['amount'] ?? 0).toDouble(),
          'date': d['date'] ?? '',
        };
      }).toList();

      setState(() {
        expenses = data;
        totalExpenses = total;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading expenses: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _addExpense(String title, double amount) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('expenses')
          .add({
        'title': title,
        'amount': amount,
        'date': now.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _fetchExpenses(); // Refresh after adding
    } catch (e) {
      print('❌ Error adding expense: $e');
    }
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Expense",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle: const TextStyle(color: Color(0xFFBA68C8)),
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter title",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFBA68C8)),
                ),
            ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: const TextStyle(color: Color(0xFFBA68C8)),
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter amount",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFBA68C8)),
                ),
            ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA68C8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                final title = titleController.text.trim();
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0;
                if (title.isNotEmpty && amount > 0) {
                  Navigator.pop(context);
                  _addExpense(title, amount);
                }
              },
              child: const Text("Add Expense",
                  style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  )),
            )
          ],
        ),
      ),
    );
  }

  String formatCurrency(double value) => "PKR ${value.toStringAsFixed(2)}";

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _applyFilter();
    final filteredTotal = _calculateFilteredTotal(filteredExpenses);

    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBA68C8),
        elevation: 0,
        title: Text(
          "Expenses",
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
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFBA68C8)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Total Expense
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
              padding: const EdgeInsets.symmetric(
                  vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Text("Total Expenses",
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(filteredTotal),
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

            // 🔹 Filter Dropdown
            Center(
              child: DropdownButton<String>(
                value: selectedFilter,
                items: ['Today', 'This Week', 'This Month', 'This Year']
                    .map((filter) => DropdownMenuItem(
                  value: filter,
                  child: Text(
                    filter,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedFilter = value;
                    });
                  }
                },
                dropdownColor: Colors.white,
                iconEnabledColor: const Color(0xFFBA68C8),
                style: GoogleFonts.poppins(
                    color: const Color(0xFFBA68C8)),
                underline: Container(
                  height: 2,
                  color: const Color(0xFFBA68C8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Expense List
            if (expenses.isEmpty)
              Text(
                "No expenses yet.",
                style: GoogleFonts.poppins(
                    color: Colors.grey, fontSize: 15),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final exp = filteredExpenses[index];
                  return Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(exp['title'],
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Text(
                                exp['date'].toString().split('T').first,
                                style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "PKR ${exp['amount'].toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFBA68C8)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () => _confirmDelete(exp['id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFBA68C8),
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
