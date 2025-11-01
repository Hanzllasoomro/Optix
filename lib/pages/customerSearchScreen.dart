import 'package:alioptical/pages/repairingReceiptScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alioptical/servers/auth/auth_service.dart';
import '../pages/customerReceiptScreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'addCustomerScreen.dart';
import 'addRepairingCustomerScreen.dart';
import 'package:flutter/services.dart';


class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String selectedType = "Customers";
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final collectionPath = selectedType == "Customers"
        ? "customers"
        : "repairing_customers";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to delete this record?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore
                  .collection('Users')
                  .doc(user.uid)
                  .collection(collectionPath)
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

  /// 🔹 Fetch current user's customers / repairing customers
  Stream<QuerySnapshot> getDataStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final collectionPath = selectedType == "Customers"
        ? "customers"
        : "repairing_customers";

    return _firestore
        .collection('Users')
        .doc(user.uid)
        .collection(collectionPath)
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
        backgroundColor: const Color(0xFFBA68C8),
        elevation: 0,
        title: Text(
          "Customers",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Dropdown
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
                          Icon(Icons.person, color: Color(0xFFBA68C8)),
                          SizedBox(width: 8),
                          Text(
                            "Customers",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Repairing",
                      child: Row(
                        children: [
                          Icon(Icons.build, color: Color(0xFFBA68C8)),
                          SizedBox(width: 8),
                          Text(
                            "Repairing",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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

            // 🔍 Search Bar
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFFBA68C8)),
                hintText: "Search by Name, Contact, or Serial...",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 List of Customers
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFBA68C8)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No records found"));
                  }

                  final query = searchController.text.toLowerCase();
                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
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
                      final data = doc.data() as Map<String, dynamic>? ?? {};
                      final name = data["name"] ?? "Unknown";
                      final contact = data["contact"] ?? "N/A";
                      final serial = data["serialNo"] != null
                          ? "#${data["serialNo"]}"
                          : "#N/A";

                      return _CustomerCard(
                        name: name,
                        contact: contact,
                        serial: serial,
                        docId: doc.id,
                        data: data,
                        onCall: () => _launchUrl("tel:$contact"),
                        onDelete: () => _confirmDelete(doc.id),
                        isWide: isWide,
                        selectedType: selectedType,
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
  final String selectedType;

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
    required this.selectedType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFBA68C8)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    contact,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // 🔘 Action Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // ☎️ Call
                        IconButton(
                        onPressed: () async {
                  final phone = data['contact']?.toString().trim() ?? '';

                  if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No phone number available")),
                  );
                  return;
                  }

                  // ✅ Clean and normalize number for Pakistan (or add your logic)
                  String formattedPhone = phone.replaceAll(RegExp(r'\s+'), '');
                  if (formattedPhone.startsWith('0')) {
                  formattedPhone = '+92${formattedPhone.substring(1)}'; // 03... → +923...
                  } else if (!formattedPhone.startsWith('+')) {
                  formattedPhone = '+$formattedPhone';
                  }

                  // ✅ Show confirmation dialog before opening dialer
                  showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                  title: const Text("Call Customer"),
                  content: Text("Do you want to call $formattedPhone?"),
                  actions: [
                  TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                  ),
                  ElevatedButton.icon(
                  icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                  label: const Text("Call Now"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                  Navigator.pop(context);

                  final Uri phoneUri = Uri(scheme: 'tel', path: formattedPhone);

                  try {
                  final launched = await launchUrl(
                  phoneUri,
                  mode: LaunchMode.externalApplication,
                  );

                  if (!launched) {
                  // ❌ No dialer app found — show message
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                  content: Text(
                  "Could not open dialer. Number copied: $formattedPhone",
                  ),
                  ),
                  );
                  }
                  } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error launching dialer: $e")),
                  );
                  }
                  },
                  ),
                  ],
                  ),
                  );
                  },

                      icon: const Icon(Icons.phone, color: Colors.green),
                          tooltip: "Call Customer",
                        ),

                        // 👁 View Receipt
                        IconButton(
                          onPressed: () async {
                            if (user == null) return;
                            final collection = selectedType == 'Repairing'
                                ? 'repairing_customers'
                                : 'customers';
                            final docSnapshot = await firestore
                                .collection('Users')
                                .doc(user.uid)
                                .collection(collection)
                                .doc(docId)
                                .get();

                            if (!docSnapshot.exists) return;

                            if (collection == 'repairing_customers') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RepairingReceiptScreen(
                                    customerId: docId,
                                    userId: user.uid,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomerReceiptScreen(
                                    customerId: docId,
                                    userId: user.uid,
                                    isRepairing: false,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.remove_red_eye,
                              color: Colors.blueAccent),
                          tooltip: "View Receipt",
                        ),

                        // ✏️ Edit
                        IconButton(
                          onPressed: () async {
                            if (user == null) return;
                            final collection = selectedType == 'Repairing'
                                ? 'repairing_customers'
                                : 'customers';

                            final docSnapshot = await firestore
                                .collection('Users')
                                .doc(user.uid)
                                .collection(collection)
                                .doc(docId)
                                .get();

                            if (!docSnapshot.exists) return;
                            final data =
                            docSnapshot.data() as Map<String, dynamic>?;

                            if (collection == 'customers') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddCustomerScreen(
                                    customerData: data,
                                    docId: docId,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddRepairingCustomerScreen(
                                        customerData: data,
                                        docId: docId,
                                      ),
                                ),
                              );
                            }
                          },
                          icon:
                          const Icon(Icons.edit, color: Colors.orangeAccent),
                          tooltip: "Edit Customer",
                        ),

                        // 💬 WhatsApp
                        IconButton(
                          onPressed: () async {
                            try {
                              final phone = data['contact']?.toString() ?? '';
                              if (phone.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("No phone number available")),
                                );
                                return;
                              }

                              String formatted =
                              phone.replaceAll(RegExp(r'\D'), '');
                              if (formatted.startsWith('0')) {
                                formatted = '92${formatted.substring(1)}';
                              }

                              final message = Uri.encodeComponent(
                                  "Hello! I'm contacting you regarding your order.");
                              final Uri whatsappUri = Uri.parse(
                                  "whatsapp://send?phone=$formatted&text=$message");

                              if (await canLaunchUrl(whatsappUri)) {
                                await launchUrl(whatsappUri,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                final webUri = Uri.parse(
                                    "https://wa.me/$formatted?text=$message");
                                if (await canLaunchUrl(webUri)) {
                                  await launchUrl(webUri,
                                      mode: LaunchMode.externalApplication);
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          },
                          icon: const FaIcon(FontAwesomeIcons.whatsapp,
                              color: Colors.green),
                          tooltip: "Contact on WhatsApp",
                        ),

                        // 🗑 Delete
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Delete Customer",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Serial Tag
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFBA68C8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                serial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
