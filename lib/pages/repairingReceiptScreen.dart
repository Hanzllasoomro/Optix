import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:url_launcher/url_launcher_string.dart'; // ✅ Required for PdfPageFormat


class RepairingReceiptScreen extends StatefulWidget {
  final String customerId;
  final String userId;

  const RepairingReceiptScreen({
    Key? key,
    required this.customerId,
    required this.userId,
  }) : super(key: key);

  @override
  State<RepairingReceiptScreen> createState() => _RepairingReceiptScreenState();
}

class _RepairingReceiptScreenState extends State<RepairingReceiptScreen> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? customerData;
  final GlobalKey _receiptKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // ✅ Fetch user info
      final userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      // ✅ Fetch repairing customer data from this user's 'repairing_customers' subcollection
      final repairingSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('repairing_customers')
          .doc(widget.customerId)
          .get();

      // ⚠️ Handle missing document
      if (!repairingSnap.exists) {
        print("⚠️ Repairing customer not found in this user's 'repairing_customers' collection");
        return;
      }

      // ✅ Update local state
      setState(() {
        userData = userSnap.data();
        customerData = repairingSnap.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print('❌ Error fetching Firestore data: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    if (userData == null || customerData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Repairing Receipt'),
          backgroundColor: const Color(0xFFBA68C8),
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFBA68C8))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repairing Receipt'),
        backgroundColor: const Color(0xFFBA68C8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              // 🧾 Only the receipt part is inside RepaintBoundary
              RepaintBoundary(
                key: _receiptKey,
                child: Container(
                  width: 400, // Keeps layout consistent
                  color: Colors.white, // Prevents black background
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Shop Info
                      Center(
                        child: Column(
                          children: [
                            Text(
                              userData!['shopName']?.toString() ?? 'Shop Name',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              userData!['address']?.toString() ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black87),
                            ),
                            Text(
                              'Ph: ${userData!['contactNumber']?.toString() ?? ''}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Customer Info
                      const Text(
                        'Customer Information:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Name', customerData!['name']),
                      _buildInfoRow('S.No', customerData!['serialNo']),
                      _buildInfoRow('Phone', customerData!['contact']),
                      _buildInfoRow('Date', customerData!['date']),
                      _buildInfoRow('Due Date', customerData!['dueDate']),
                      _buildInfoRow('Frame', customerData!['frameDetails']),
                      _buildInfoRow('Lens', customerData!['lensDetails']),
                      const SizedBox(height: 16),

                      // 🔹 Financial Details
                      const Text(
                        'Financial Details:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildFinanceTable(customerData!),
                      const SizedBox(height: 20),

                      const Text(
                        'Note:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. 50% Advance Required for Order Confirmation.\n'
                            '2. No Refund on Completed Orders.\n'
                            '3. Not Responsible for Damaged Frames or Lenses.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🟣 Buttons are outside RepaintBoundary (won’t appear in PDF)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBA68C8),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text('Share',
                        style: TextStyle(color: Colors.white)),
                    onPressed: _shareReceipt,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );


  }

  // 🔹 Info Row
  Widget _buildInfoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? ''),
        ],
      ),
    );
  }

  // 🔹 Finance Table
  Widget _buildFinanceTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.black54),
      children: [
        TableRow(children: [
          _tableCell('Total'),
          _tableCell('${data['total']?.toString() ?? ''} Pkr'),
        ]),
        TableRow(children: [
          _tableCell('Advance'),
          _tableCell('${data['advance']?.toString() ?? ''} Pkr'),
        ]),
        TableRow(children: [
          _tableCell('Balance'),
          _tableCell('${data['balance']?.toString() ?? ''} Pkr'),
        ]),
      ],
    );
  }

  static Widget _tableCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  // 🔹 Generate HTML content for PDF
  String get _htmlContent {
    return '''
<h1 style="text-align:center;">${userData!['shopName']}</h1>
<p style="text-align:center;">${userData!['address']}<br>Ph: ${userData!['contactNumber']}</p>
<hr>
<h2>Repairing Receipt</h2>
<p><b>Name:</b> ${customerData!['name']}<br>
<b>S.No:</b> ${customerData!['serialNo']}<br>
<b>Phone:</b> ${customerData!['contact']}<br>
<b>Date:</b> ${customerData!['date']}<br>
<b>Due Date:</b> ${customerData!['dueDate']}<br>
<b>Frame:</b> ${customerData!['frameDetails']}<br>
<b>Lens:</b> ${customerData!['lensDetails']}</p>

<h3>Financial Details</h3>
<p>Total: ${customerData!['total']} Pkr<br>
Advance: ${customerData!['advance']} Pkr<br>
Balance: ${customerData!['balance']} Pkr</p>
''';
  }




  Future<void> _shareReceipt() async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📤 Sharing is not supported on Web.')),
        );
        return;
      }

      // 🕒 Wait for widget to finish rendering
      RenderRepaintBoundary boundary =
      _receiptKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // 🖼️ Capture widget as image
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 🧾 Create a properly scaled PDF using the image
      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(pngBytes);

      pdf.addPage(
        pw.Page(
          // You can use A4 or 80mm thermal size
          pageFormat: PdfPageFormat.a4, // or: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity)
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                imageProvider,
                fit: pw.BoxFit.contain, // ensures full image visible
              ),
            );
          },
        ),
      );

      // 📂 Save the PDF temporarily
      final tempDir = await getTemporaryDirectory();
      final pdfPath = '${tempDir.path}/${customerData!['name']}_Receipt.pdf';
      final pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(await pdf.save());

      // ✅ Convert phone number from 03xxxxxxxxx → 923xxxxxxxxx
      String rawNumber = customerData!['contact'] ?? '';
      String phoneNumber =
      rawNumber.startsWith('0') ? '92${rawNumber.substring(1)}' : rawNumber;

      // 📤 Share PDF file (user can choose WhatsApp, Gmail, Print, etc.)
      await Share.shareXFiles(
        [XFile(pdfPath)],
        text:
        'Hello ${customerData!['name']}! Here is your repairing receipt in PDF format.',
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error sharing receipt: $e')),
      );
    }
  }


}
