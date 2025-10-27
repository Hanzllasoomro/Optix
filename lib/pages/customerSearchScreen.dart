import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alioptical/servers/auth/auth_service.dart';
import '../components/bottomNavBar.dart';
import '../pages/customerReceiptScreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String selectedType = "Customers"; // Dropdown default

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void logout() {
    final _authService = AuthService();
    _authService.signOut();
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(String docId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore
                  .collection(selectedType == "Customers"
                  ? "customers"
                  : "repairing_customers")
                  .doc(docId)
                  .delete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // Firestore Stream depending on dropdown
  Stream<QuerySnapshot> getDataStream() {
    final collection = selectedType == "Customers"
        ? "customers"
        : "repairing_customers";
    return _firestore
        .collection(collection)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Text(
          "Customers",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(
                      value: "Customers",
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Customers",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Repairing",
                      child: Row(
                        children: [
                          Icon(Icons.build, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Repairing",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}), // triggers rebuild for filter
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.red),
                hintText: "Search by Name, Contact, or Serial...",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List of Customers (StreamBuilder)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No records found"));
                  }

                  final query = searchController.text.toLowerCase();
                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data["name"] ?? "").toString().toLowerCase();
                    final contact =
                    (data["contact"] ?? "").toString().toLowerCase();
                    final serial =
                    (data["serialNo"] ?? "").toString().toLowerCase();
                    return name.contains(query) ||
                        contact.contains(query) ||
                        serial.contains(query);
                  }).toList();

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final name = data["name"] ?? "Unknown";
                      final contact = data["contact"] ?? "N/A";
                      final serial =
                      data["serialNo"] != null ? "#${data["serialNo"]}" : "#N/A";

                      return _CustomerCard(
                        name: name,
                        contact: contact,
                        serial: serial,
                        docId: doc.id,
                        data: data,
                        onCall: () => _launchUrl("tel:$contact"),
                        onDelete: () => _confirmDelete(doc.id),
                        isWide: isWide,
                      );

                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final String name;
  final String contact;
  final String serial;
  final String docId;
  final Map<String, dynamic> data;
  final VoidCallback onCall;
  final VoidCallback onDelete;
  final bool isWide;

  const _CustomerCard({
    Key? key,
    required this.name,
    required this.contact,
    required this.serial,
    required this.docId,
    required this.data,
    required this.onCall,
    required this.onDelete,
    required this.isWide,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.redAccent),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: isWide ? 30 : 24,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "?",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  Text(
                    contact,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onCall,
                        icon: const Icon(Icons.phone, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () async {
                          try {
                            final FirebaseFirestore firestore = FirebaseFirestore.instance;

                            // Determine which collection to query
                            final String category = data['category'] ?? 'Customers';
                            final String collection = category == 'Repairing'
                                ? 'repairing_customers'
                                : 'customers';

                            // Fetch the document from Firestore
                            final DocumentSnapshot docSnapshot =
                            await firestore.collection(collection).doc(docId).get();

                            if (!docSnapshot.exists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Record not found in $collection")),
                              );
                              return;
                            }

                            final docData = docSnapshot.data() as Map<String, dynamic>?;

                            if (docData == null ||
                                !(docData.containsKey('userId') && docData.containsKey('shopId'))) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("User or Shop ID missing in $collection document")),
                              );
                              return;
                            }

                            final String userId = docData['userId'];
                            final String shopId = docData['shopId'];

                            // ✅ Navigate to receipt screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerReceiptScreen(
                                  customerId: docId,
                                  userId: userId,
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error fetching record: $e")),
                            );
                          }
                        },
                        icon: const Icon(Icons.remove_red_eye, color: Colors.blueAccent),
                      ),
                      IconButton(
                        onPressed: (){},
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: (){},
                        icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                serial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
