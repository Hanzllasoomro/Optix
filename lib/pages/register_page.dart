import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../servers/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  // 🔹 Controllers
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  // 🔹 Registration Function
  void register(BuildContext context) async {
    final auth = AuthService();

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showErrorDialog(context, "Passwords do not match");
      return;
    }

    try {
      await auth.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        shopName: _shopNameController.text.trim(),
        contactNumber: _contactController.text.trim(),
      );

      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Success"),
          content: Text("Account created successfully!"),
        ),
      );
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }


  // 🔹 Error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registration Failed"),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔴 Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isWide ? 60 : 50,
                horizontal: isWide ? 40 : 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.store,
                    color: Colors.white,
                    size: isWide ? 80 : 60,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Ali Opticals",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isWide ? 28 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 70),

            // 🟢 Title
            Text(
              "Create an Account",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: isWide ? 20 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 25),

            // 🟢 Shop Name Field
            Container(
              width: isWide ? 400 : 320,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _shopNameController,
                decoration: InputDecoration(
                  labelText: "Shop Name",
                  labelStyle: const TextStyle(color: Color(0xFFD32F2F)),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Enter your shop name",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD32F2F)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🟢 Contact Number Field
            Container(
              width: isWide ? 400 : 320,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  labelStyle: const TextStyle(color: Color(0xFFD32F2F)),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Enter your contact number",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD32F2F)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🟢 Email Field
            Container(
              width: isWide ? 400 : 320,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Color(0xFFD32F2F)),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Enter your email",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD32F2F)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🟢 Password Field
            Container(
              width: isWide ? 400 : 320,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Color(0xFFD32F2F)),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD32F2F)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🟢 Confirm Password Field
            Container(
              width: isWide ? 400 : 320,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  labelStyle: const TextStyle(color: Color(0xFFD32F2F)),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Re-enter your password",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD32F2F)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔵 Register Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 120 : 100,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => register(context),
              child: Text(
                "Register",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🔸 Already have an account?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login now",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
