import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // 👈 Add this in pubspec.yaml
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatelessWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      body: SingleChildScrollView(
        child: Column(
            children: [
              // 🌈 Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isWide ? 60 : 50,
                  horizontal: isWide ? 40 : 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBA68C8), Color(0xFFBA68C8)],
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
                      "Optix",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isWide ? 28 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),

              // 💬 Info Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Text(
                      "Online registration is currently not available.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: isWide ? 18 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "To create an account or register your shop, please contact our team:",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
                        fontSize: isWide ? 15 : 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 📞 Contact Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA68C8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBA68C8).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_rounded,
                        color: const Color(0xFFBA68C8),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Hanzlla Soomro",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "For Registration & Support. Click on number",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // WhatsApp Row
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        splashColor: Colors.white24,
                        onTap: () async {
                          const phoneNumber = "923106387577"; // ✅ no + for wa.me links
                          final whatsappUrl = Uri.parse("https://wa.me/$phoneNumber");
                          if (await canLaunchUrl(whatsappUrl)) {
                            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("WhatsApp not installed or can't be opened")),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text(
                                "+92 3106387577",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  decorationColor: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )


                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 🔸 Back to login
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBA68C8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 80 : 60,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onTap,
                child: Text(
                  "Back to Login",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      );


  }
}
