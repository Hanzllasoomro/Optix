import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../components/bottomNavBar.dart'; // Adjust this path if needed

class AddRepairingCustomerScreen extends StatefulWidget {
  const AddRepairingCustomerScreen({Key? key}) : super(key: key);

  @override
  State<AddRepairingCustomerScreen> createState() =>
      _AddRepairingCustomerScreenState();
}

class _AddRepairingCustomerScreenState
    extends State<AddRepairingCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  int _serialNo = 0;
  bool _loadingSerial = true;
  bool _submitting = false;

  final CollectionReference _repairRef =
  FirebaseFirestore.instance.collection('repairing_customers');

  @override
  void initState() {
    super.initState();
    _fetchNextSerial();

    // auto-balance update
    _totalController.addListener(_calculateBalance);
    _advanceController.addListener(_calculateBalance);
  }

  Future<void> _fetchNextSerial() async {
    try {
      setState(() => _loadingSerial = true);
      final snapshot = await _repairRef
          .orderBy('serialNo', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        _serialNo = 1000;
      } else {
        final last = snapshot.docs.first.data() as Map<String, dynamic>;
        final lastSerial = (last['serialNo'] is int)
            ? last['serialNo'] as int
            : int.tryParse('${last['serialNo']}') ?? 1000;
        _serialNo = lastSerial + 1;
      }
    } catch (e) {
      _serialNo = 1000;
      debugPrint('Serial fetch error: $e');
    } finally {
      setState(() => _loadingSerial = false);
    }
  }

  void _calculateBalance() {
    final total = double.tryParse(_totalController.text) ?? 0;
    final advance = double.tryParse(_advanceController.text) ?? 0;
    _balanceController.text = (total - advance).toStringAsFixed(2);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String _formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final data = {
        'serialNo': _serialNo,
        'name': _nameController.text.trim(),
        'contact': _contactController.text.trim(),
        'total': double.tryParse(_totalController.text) ?? 0.0,
        'advance': double.tryParse(_advanceController.text) ?? 0.0,
        'balance': double.tryParse(_balanceController.text) ?? 0.0,
        'date': _formatDate(_selectedDate),
        'dueDate': _dueDate == null ? null : _formatDate(_dueDate!),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _repairRef.add(data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repairing customer added successfully')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('Submit error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add customer: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildSerialBadge() {
    return _loadingSerial
        ? const Chip(label: Text('Serial# ...'), backgroundColor: Colors.green)
        : Chip(
      label: Text('Serial# $_serialNo',
          style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? Function(String?)? validator,
    bool readOnly = false,
    Widget? prefix,
    Widget? suffix,
    void Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 14);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: Text(
          'Repairing Customers',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: implement signout logic here
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: _buildSerialBadge()),
          ),
        ],
      ),

      // ✅ integrated your BottomNavBar here
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _loadingSerial && _serialNo == 0
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Name',
                  controller: _nameController,
                  hint: 'Full name',
                  validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter name' : null,
                  prefix: const Icon(Icons.person),
                ),
                spacing,
                _buildTextField(
                  label: 'Contact Number',
                  controller: _contactController,
                  hint: '03XXXXXXXXX',
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Enter contact number'
                      : null,
                  prefix: const Icon(Icons.phone),
                ),
                spacing,
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Total Amount',
                        controller: _totalController,
                        hint: '0.00',
                        keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Enter total'
                            : null,
                        prefix: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Advance Payment',
                        controller: _advanceController,
                        hint: '0.00',
                        keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) => null,
                        prefix: const Icon(Icons.money_off),
                      ),
                    ),
                  ],
                ),
                spacing,
                _buildTextField(
                  label: 'Balance',
                  controller: _balanceController,
                  hint: 'Calculated automatically',
                  readOnly: true,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  prefix:
                  const Icon(Icons.account_balance_wallet_outlined),
                ),
                spacing,
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            label: 'Date',
                            controller: TextEditingController(
                                text: _formatDate(_selectedDate)),
                            readOnly: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDueDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            label: 'Due Date',
                            controller: TextEditingController(
                                text: _dueDate == null
                                    ? ''
                                    : _formatDate(_dueDate!)),
                            readOnly: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text('Submit',
                        style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
