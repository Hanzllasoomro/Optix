import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List, ByteData;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';




class CustomerReceiptScreen extends StatefulWidget {
  final String customerId;
  final String userId;
  final bool isRepairing; // 👈 new

  const CustomerReceiptScreen({
    Key? key,
    required this.customerId,
    required this.userId,
    this.isRepairing = false, // default false
  }) : super(key: key);

  @override
  State<CustomerReceiptScreen> createState() => _CustomerReceiptScreenState();
}

class _CustomerReceiptScreenState extends State<CustomerReceiptScreen> {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? customerData;
  final GlobalKey _receiptKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    fetchData();
  }


  Future<void> printReceipt({
    required BuildContext context,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> customerData,
  }) async {
    try {
      // 🚫 Web check
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🖨️ Printing not supported on Web')),
        );
        return;
      }

      // ✅ Android-only
      if (!Platform.isAndroid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printing supported only on Android')),
        );
        return;
      }

      // 🧾 Create receipt HTML
      final htmlContent = '''
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; margin: 24px; }
        h1, h2, h3 { text-align: center; color: #4A148C; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #555; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
        p { font-size: 14px; }
      </style>
    </head>
    <body>
      <h1>${userData['shopName'] ?? 'Shop Name'}</h1>
      <p>${userData['address'] ?? ''}<br>Ph: ${userData['contactNumber'] ?? ''}</p>
      <hr>
      <h2>Customer Receipt</h2>
      <p>
        <b>Name:</b> ${customerData['name'] ?? ''}<br>
        <b>S.No:</b> ${customerData['serialNo'] ?? ''}<br>
        <b>Phone:</b> ${customerData['contact'] ?? ''}<br>
        <b>Date:</b> ${customerData['date'] ?? ''}<br>
        <b>Due Date:</b> ${customerData['dueDate'] ?? ''}<br>
        <b>Frame:</b> ${customerData['frameDetails'] ?? ''}<br>
        <b>Lens:</b> ${customerData['lensDetails'] ?? ''}
      </p>

      <h3>Vision Details</h3>
      <table>
        <tr>
          <th></th><th>SPH</th><th>CYL</th><th>AXIS</th><th>VA</th>
        </tr>
        <tr>
          <td>Right Eye</td>
          <td>${customerData['eyeData']?['right']?['sph'] ?? ''}</td>
          <td>${customerData['eyeData']?['right']?['cyl'] ?? ''}</td>
          <td>${customerData['eyeData']?['right']?['axis'] ?? ''}</td>
          <td>${customerData['eyeData']?['right']?['va'] ?? ''}</td>
        </tr>
        <tr>
          <td>Left Eye</td>
          <td>${customerData['eyeData']?['left']?['sph'] ?? ''}</td>
          <td>${customerData['eyeData']?['left']?['cyl'] ?? ''}</td>
          <td>${customerData['eyeData']?['left']?['axis'] ?? ''}</td>
          <td>${customerData['eyeData']?['left']?['va'] ?? ''}</td>
        </tr>
        <tr>
          <td>ADD</td>
          <td>${customerData['eyeData']?['add']?['add1'] ?? ''}</td>
          <td>${customerData['eyeData']?['add']?['add2'] ?? ''}</td>
          <td></td><td></td>
        </tr>
        <tr>
          <td>IPD</td>
          <td>${customerData['eyeData']?['ipd']?['ipd1'] ?? ''}</td>
          <td>${customerData['eyeData']?['ipd']?['ipd2'] ?? ''}</td>
          <td></td><td></td>
        </tr>
      </table>

      <h3>Financial Details</h3>
      <p>
        <b>Total:</b> ${customerData['total'] ?? ''} PKR<br>
        <b>Advance:</b> ${customerData['advance'] ?? ''} PKR<br>
        <b>Balance:</b> ${customerData['balance'] ?? ''} PKR
      </p>

      <p style="font-size:13px; color:#555; margin-top:24px;">
        <b>Note:</b><br>
        1. 50% Advance Required for Order Confirmation.<br>
        2. No Refund on Completed Orders.<br>
        3. Not Responsible for Damaged Frames or Lenses.
      </p>
    </body>
    </html>
    ''';

      // 🧩 Convert HTML → PDF
      final pdfBytes = await Printing.convertHtml(
        format: PdfPageFormat.a4,
        html: htmlContent,
      );

      // 🖨️ Open Android print/save dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: '${customerData['name']}_Receipt.pdf',
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error while printing: $e')),
      );
    }
  }

  Future<void> fetchData() async {
    try {
      // ✅ Fetch user info
      final userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();

      // ✅ Fetch customer data from this user's 'customers' subcollection
      final customerSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('customers')
          .doc(widget.customerId)
          .get();

      // ⚠️ Handle missing document
      if (!customerSnap.exists) {
        print("⚠️ Customer not found in this user's 'customers' collection");
        return;
      }

      // ✅ Update local state
      setState(() {
        userData = userSnap.data();
        customerData = customerSnap.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print('❌ Error fetching Firestore data: $e');
    }
  }



  bool isDueDatePassed(String dueDateStr) {
    try {
      final dueDate = DateTime.parse(dueDateStr);
      return DateTime.now().isAfter(dueDate);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null || customerData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Customer Receipt'),
          backgroundColor: Color(0xFFBA68C8),
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFBA68C8))),
      );
    }

    final bool duePassed = isDueDatePassed(customerData!['dueDate']);
    final Color dueColor = duePassed ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Receipt'),
        backgroundColor: const Color(0xFFBA68C8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              // 🧾 Only the receipt part is captured
              RepaintBoundary(
                key: _receiptKey,
                child: Container(
                  width: 400,
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Shop Info
                      Center(
                        child: Column(
                          children: [
                            Text(
                              userData!['shopName'] ?? 'Shop Name',
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            Text(userData!['address'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black87)),
                            Text('Ph: ${userData!['contactNumber'] ?? ''}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),

                      // 🔹 Customer Info
                      const Text(
                        'Customer Information:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      buildInfoRow('Name', customerData!['name']),
                      buildInfoRow('S.No', customerData!['serialNo'].toString()),
                      buildInfoRow('Phone', customerData!['contact']),
                      buildInfoRow('Date', customerData!['date']),
                      Row(
                        children: [
                          const Text('Due Date: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            customerData!['dueDate'],
                            style: TextStyle(
                              color: isDueDatePassed(customerData!['dueDate'])
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      buildInfoRow('Frame', customerData!['frameDetails']),
                      buildInfoRow('Lens', customerData!['lensDetails']),
                      const SizedBox(height: 16),

                      // 🔹 Vision Details (if exist)
                      if (customerData!['eyeData'] != null) ...[
                        const Text(
                          'Vision:',
                          style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        buildVisionTable(customerData!),
                        const SizedBox(height: 16),
                      ],

                      // 🔹 Financial Details
                      const Text(
                        'Financial Details:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      buildFinanceTable(customerData!),
                      const SizedBox(height: 20),

                      // 🔹 Notes
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

              // 🟣 Buttons are OUTSIDE RepaintBoundary
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
                    label: const Text(
                      'Share',
                      style: TextStyle(color: Colors.white),
                    ),
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

  Widget buildInfoRow(String title, String value) {
    return Row(
      children: [
        Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget buildVisionTable(Map<String, dynamic> data) {
    final eyeData = (data['eyeData'] ?? {}) as Map<String, dynamic>;
    final right = (eyeData['right'] ?? {}) as Map<String, dynamic>;
    final left = (eyeData['left'] ?? {}) as Map<String, dynamic>;
    final add = (eyeData['add'] ?? {}) as Map<String, dynamic>;
    final ipd = (eyeData['ipd'] ?? {}) as Map<String, dynamic>;

    return Table(
      border: TableBorder.all(color: Colors.black54),
      children: [
         TableRow(
          decoration: BoxDecoration(color: Color(0xFFF2F2F2)),
          children: [
            _tableHeader(''),
            _tableHeader('SPH'),
            _tableHeader('CYL'),
            _tableHeader('AXIS'),
            _tableHeader('VA'),
          ],
        ),
        TableRow(children: [
          _tableCell('Rt Eye'),
          _tableCell(right['sph'] ?? ''),
          _tableCell(right['cyl'] ?? ''),
          _tableCell(right['axis'] ?? ''),
          _tableCell(right['va'] ?? ''),
        ]),
        TableRow(children: [
          _tableCell('Lt Eye'),
          _tableCell(left['sph'] ?? ''),
          _tableCell(left['cyl'] ?? ''),
          _tableCell(left['axis'] ?? ''),
          _tableCell(left['va'] ?? ''),
        ]),
        TableRow(children: [
          _tableCell('ADD'),
          _tableCell(add['add1'] ?? ''),
          _tableCell(add['add2'] ?? ''),
          _tableCell(''),
          _tableCell(''),
        ]),
        TableRow(children: [
          _tableCell('IPD'),
          _tableCell(ipd['ipd1'] ?? ''),
          _tableCell(ipd['ipd2'] ?? ''),
          _tableCell(''),
          _tableCell(''),
        ]),
      ],
    );
  }

  Widget buildFinanceTable(Map<String, dynamic> data) {
    return Table(
      border: TableBorder.all(color: Colors.black54),
      children: [
        TableRow(children: [
          _tableCell('Total'),
          _tableCell('${data['total']} Pkr'),
        ]),
        TableRow(children: [
          _tableCell('Advance'),
          _tableCell('${data['advance']} Pkr'),
        ]),
        TableRow(children: [
          _tableCell('Balance'),
          _tableCell('${data['balance']} Pkr'),
        ]),
      ],
    );
  }

  static Widget _tableHeader(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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

