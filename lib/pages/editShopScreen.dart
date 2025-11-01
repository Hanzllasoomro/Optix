import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './myShopScreen.dart';

class EditShopScreen extends StatefulWidget {
  const EditShopScreen({Key? key}) : super(key: key);

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();

  // Fields
  String shopName = "";
  String email = "";
  String contact = "";
  String address = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          shopName = data['shopName'] ?? "";
          email = data['email'] ?? user.email ?? "";
          contact = data['contactNumber'] ?? "";
          address = data['address'] ?? "";
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // ✅ Update Firestore data (email not changed)
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'shopName': shopName,
        'email': email, // keep same email
        'contactNumber': contact,
        'address': address,
        'updatedAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details saved successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyShopScreen(
            shopName: shopName,
            email: email,
            contact: contact,
            address: address,
            subscriptionStatus: "Active",
            daysLeft: 9,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFBA68C8))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFBA68C8),
        title: Text(
          "Edit Shop Details",
          style: GoogleFonts.poppins(
            color: Colors.white,
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
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 100 : 20,
          vertical: 30,
        ),
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Shop Name"),
                _buildTextField(
                  initialValue: shopName,
                  onSaved: (val) => shopName = val ?? "",
                ),
                const SizedBox(height: 16),

                _buildLabel("Email"),
                // 👇 Email field is now read-only
                _buildTextField(
                  initialValue: email,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true, // 👈 Prevent editing
                  onSaved: (val) => email = val ?? "",
                ),
                const SizedBox(height: 16),

                _buildLabel("Contact Number"),
                _buildTextField(
                  initialValue: contact,
                  keyboardType: TextInputType.phone,
                  onSaved: (val) => contact = val ?? "",
                ),
                const SizedBox(height: 16),

                _buildLabel("Address"),
                _buildTextField(
                  initialValue: address,
                  onSaved: (val) => address = val ?? "",
                ),
                const SizedBox(height: 30),

                _buildActionButton(
                  label: "Save Details 💾",
                  color: const Color(0xFFBA68C8),
                  onPressed: _saveDetails,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String initialValue,
    TextInputType? keyboardType,
    required FormFieldSetter<String> onSaved,
    bool readOnly = false, // 👈 Added parameter
  }) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFBA68C8), width: 1.2),
        ),
      ),
      validator: (val) =>
      (val == null || val.isEmpty) ? "This field cannot be empty" : null,
      onSaved: onSaved,
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
