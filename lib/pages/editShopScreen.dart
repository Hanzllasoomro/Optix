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

  // Mock initial data (pretend fetched from database)
  String shopName = "Tariq Eye Corner";
  String email = "tariqopticals@gmail.com";
  String contact = "03126017600";
  String address = "Main Saddar, Karachi";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFD32F2F),
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
                _buildTextField(
                  initialValue: email,
                  keyboardType: TextInputType.emailAddress,
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

                // 🔹 Save Button
                _buildActionButton(
                  label: "Save Details 💾",
                  color: const Color(0xFFD32F2F),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Details saved successfully!")),
                      );

                      // ✅ Pass updated data back to MyShopScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyShopScreen(
                            shopName: shopName,
                            email: email,
                            contact: contact,
                            address: address,
                            totalCustomers: 250,
                            opticsCustomers: 180,
                            repairingCustomers: 70,
                            subscriptionStatus: "Active",
                            daysLeft: 9,
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 15),

                // 🔹 Reset Password
                _buildActionButton(
                  label: "Reset Password 🔒",
                  color: Colors.orange.shade700,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Redirecting to Reset Password...")),
                    );
                    // TODO: Navigate to ResetPasswordScreen
                  },
                ),
                const SizedBox(height: 15),

                // 🔹 Delete Account
                _buildActionButton(
                  label: "Delete Account 🗑️",
                  color: Colors.grey.shade700,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Shop Account"),
                        content: const Text(
                            "Are you sure you want to permanently delete this account?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Account deleted successfully.")),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- Helper Widgets -----------------------

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
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
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
