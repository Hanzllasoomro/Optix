import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  TextEditingController searchController = TextEditingController();

  // Mock data (Replace with DB fetch logic)
  List<Map<String, dynamic>> allCustomers = [
    {
      "name": "Hanzlla Soomro",
      "contact": "035552864284",
      "serial": "#1000",
    },
    {
      "name": "Ali Khan",
      "contact": "03451234567",
      "serial": "#1001",
    },
  ];

  List<Map<String, dynamic>> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    filteredCustomers = allCustomers;
  }

  void searchCustomer(String query) {
    setState(() {
      filteredCustomers = allCustomers.where((customer) {
        final name = customer["name"].toLowerCase();
        final contact = customer["contact"];
        final serial = customer["serial"].toLowerCase();
        return name.contains(query.toLowerCase()) ||
            contact.contains(query) ||
            serial.contains(query.toLowerCase());
      }).toList();
    });
  }

  // Helper: launch phone or WhatsApp
  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Customer"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                filteredCustomers.removeWhere((c) => c["name"] == name);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
            onPressed: () {},
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
                  value: "Customers",
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
                  onChanged: (value) {},
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: searchController,
              onChanged: searchCustomer,
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

            // Customer List
            Expanded(
              child: ListView.builder(
                itemCount: filteredCustomers.length,
                itemBuilder: (context, index) {
                  final customer = filteredCustomers[index];
                  return _CustomerCard(
                    name: customer["name"],
                    contact: customer["contact"],
                    serial: customer["serial"],
                    onCall: () => _launchUrl("tel:${customer["contact"]}"),
                    onView: () {},
                    onEdit: () {},
                    onWhatsApp: () => _launchUrl(
                        "https://wa.me/${customer["contact"].replaceAll("+", "")}"),
                    onDelete: () => _confirmDelete(customer["name"]),
                    isWide: isWide,
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _BottomNavItem(icon: Icons.build, label: "Repairing"),
              SizedBox(width: 48), // Space for FAB
              _BottomNavItem(icon: Icons.search, label: "Search", active: true),
              _BottomNavItem(icon: Icons.storefront, label: "Shop"),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final String name;
  final String contact;
  final String serial;
  final VoidCallback onCall;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onWhatsApp;
  final VoidCallback onDelete;
  final bool isWide;

  const _CustomerCard({
    Key? key,
    required this.name,
    required this.contact,
    required this.serial,
    required this.onCall,
    required this.onView,
    required this.onEdit,
    required this.onWhatsApp,
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
            // Avatar / Initial
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
            // Info
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
                        onPressed: onView,
                        icon: const Icon(Icons.remove_red_eye,
                            color: Colors.blueAccent),
                      ),
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: onWhatsApp,
                        icon: const Icon(Icons.face, color: Colors.green),
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
            // Serial number badge
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48, // Ensures fixed height for bottom bar item
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.red : Colors.grey, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

