import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddCustomerScreen extends StatefulWidget {
  final Map<String, dynamic>? customerData; // optional data for editing
  final String? docId; // Firestore doc ID

  const AddCustomerScreen({Key? key, this.customerData, this.docId}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}
class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _gender = 'Male';

  // Eye Data controllers
  final TextEditingController _rSph = TextEditingController();
  final TextEditingController _rCyl = TextEditingController();
  final TextEditingController _rAxis = TextEditingController();
  final TextEditingController _rVa = TextEditingController();

  final TextEditingController _lSph = TextEditingController();
  final TextEditingController _lCyl = TextEditingController();
  final TextEditingController _lAxis = TextEditingController();
  final TextEditingController _lVa = TextEditingController();

  final TextEditingController _add1 = TextEditingController();
  final TextEditingController _add2 = TextEditingController();

  final TextEditingController _ipd1 = TextEditingController();
  final TextEditingController _ipd2 = TextEditingController();

  // Other details
  final TextEditingController _frameController = TextEditingController();
  final TextEditingController _lensController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  // Payment
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  // Dates
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  // Serial fetched from Firestore
  int _serialNo = 0;
  bool _loadingSerial = true;
  bool _submitting = false;

  // final CollectionReference _customersRef =
  // FirebaseFirestore.instance.collection('customers');
  CollectionReference<Map<String, dynamic>> get _customersRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('customers');
  }


  @override
  void initState() {
    super.initState();
    _fetchNextSerial();

    _totalController.addListener(_calculateBalance);
    _advanceController.addListener(_calculateBalance);

    if (widget.customerData != null) {
      final data = widget.customerData!;
      _nameController.text = data['name'] ?? '';
      _contactController.text = data['contact'] ?? '';
      _gender = data['gender'] ?? 'Male';

      final eye = data['eyeData'] ?? {};
      final right = eye['right'] ?? {};
      final left = eye['left'] ?? {};
      final add = eye['add'] ?? {};
      final ipd = eye['ipd'] ?? {};

      _rSph.text = right['sph'] ?? '';
      _rCyl.text = right['cyl'] ?? '';
      _rAxis.text = right['axis'] ?? '';
      _rVa.text = right['va'] ?? '';

      _lSph.text = left['sph'] ?? '';
      _lCyl.text = left['cyl'] ?? '';
      _lAxis.text = left['axis'] ?? '';
      _lVa.text = left['va'] ?? '';

      _add1.text = add['add1'] ?? '';
      _add2.text = add['add2'] ?? '';

      _ipd1.text = ipd['ipd1'] ?? '';
      _ipd2.text = ipd['ipd2'] ?? '';

      _frameController.text = data['frameDetails'] ?? '';
      _lensController.text = data['lensDetails'] ?? '';
      _remarksController.text = data['remarks'] ?? '';

      _totalController.text = (data['total'] ?? 0.0).toString();
      _advanceController.text = (data['advance'] ?? 0.0).toString();
      _balanceController.text = (data['balance'] ?? 0.0).toString();

      if (data['date'] != null) {
        _selectedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
      }
      if (data['dueDate'] != null) {
        _dueDate = DateTime.tryParse(data['dueDate']);
      }
      if (data['serialNo'] != null) {
        _serialNo = data['serialNo'];
        _loadingSerial = false;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();

    _rSph.dispose();
    _rCyl.dispose();
    _rAxis.dispose();
    _rVa.dispose();

    _lSph.dispose();
    _lCyl.dispose();
    _lAxis.dispose();
    _lVa.dispose();

    _add1.dispose();
    _add2.dispose();

    _ipd1.dispose();
    _ipd2.dispose();

    _frameController.dispose();
    _lensController.dispose();
    _remarksController.dispose();

    _totalController.dispose();
    _advanceController.dispose();
    _balanceController.dispose();

    super.dispose();
  }

  Future<void> _fetchNextSerial() async {
    try {
      setState(() => _loadingSerial = true);
      final snapshot = await _customersRef
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
      debugPrint('Error fetching serial: $e');
    } finally {
      setState(() => _loadingSerial = false);
    }
  }

  void _calculateBalance() {
    final total =
        double.tryParse(_totalController.text.replaceAll(',', '')) ?? 0;
    final advance =
        double.tryParse(_advanceController.text.replaceAll(',', '')) ?? 0;
    _balanceController.text = (total - advance).toStringAsFixed(2);
  }

  Future<void> _pickDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickDueDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String _formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Map<String, dynamic> _collectEyeData() {
    return {
      'right': {
        'sph': _rSph.text.trim(),
        'cyl': _rCyl.text.trim(),
        'axis': _rAxis.text.trim(),
        'va': _rVa.text.trim(),
      },
      'left': {
        'sph': _lSph.text.trim(),
        'cyl': _lCyl.text.trim(),
        'axis': _lAxis.text.trim(),
        'va': _lVa.text.trim(),
      },
      'add': {
        'add1': _add1.text.trim(),
        'add2': _add2.text.trim(),
      },
      'ipd': {
        'ipd1': _ipd1.text.trim(),
        'ipd2': _ipd2.text.trim(),
      },
    };
  }

  Future<void> _submit() async {
    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);

    final data = {
      'serialNo': _serialNo,
      'name': _nameController.text.trim(),
      'contact': _contactController.text.trim(),
      'gender': _gender,
      'eyeData': _collectEyeData(),
      'frameDetails': _frameController.text.trim(),
      'lensDetails': _lensController.text.trim(),
      'remarks': _remarksController.text.trim(),
      'total': double.tryParse(_totalController.text) ?? 0.0,
      'advance': double.tryParse(_advanceController.text) ?? 0.0,
      'balance': double.tryParse(_balanceController.text) ?? 0.0,
      'date': _formatDate(_selectedDate),
      'dueDate': _dueDate == null ? null : _formatDate(_dueDate!),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.docId != null) {
        // Update existing customer
        await _customersRef.doc(widget.docId).update(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer updated successfully')),
        );
      } else {
        // Add new customer
        await _customersRef.add(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
      }

      Navigator.of(context).pop(true); // Return true to refresh previous screen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save customer: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }


  Widget _buildSerialBadge() {
    if (_loadingSerial) {
      return const Chip(label: Text('Serial# ...'), backgroundColor: Colors.green);
    }
    return Chip(
      label: Text('Serial# $_serialNo', style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    );
  }

  Widget _buildEyeCell(TextEditingController c, {String hint = ''}) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        controller: c,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildEyeTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Eye Data',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBA68C8))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFBA68C8)),
              borderRadius: BorderRadius.circular(2)),
          child: Column(
            children: [
              // header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white,
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: Center(child: Text(''))),
                    Expanded(flex: 2, child: Center(child: Text('SPH', style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(flex: 2, child: Center(child: Text('CYL', style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(flex: 2, child: Center(child: Text('AXIS', style: TextStyle(fontWeight: FontWeight.bold)))),
                    Expanded(flex: 2, child: Center(child: Text('VA', style: TextStyle(fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFBA68C8), height: 0),
              // RIGHT
              Row(
                children: [
                  Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(8), child: const Center(child: Text('RIGHT\nEYE', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_rSph))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_rCyl))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_rAxis))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_rVa))),
                ],
              ),
              const Divider(color: Color(0xFFBA68C8), height: 0),
              // LEFT
              Row(
                children: [
                  Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(8), child: const Center(child: Text('LEFT\nEYE', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_lSph))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_lCyl))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_lAxis))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_lVa))),
                ],
              ),
              const Divider(color: Color(0xFFBA68C8), height: 0),
              // ADD
              Row(
                children: [
                  Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(8), child: const Center(child: Text('ADD', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_add1))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_add2))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(TextEditingController(), hint: ''))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(TextEditingController(), hint: ''))),
                ],
              ),
              const Divider(color: Color(0xFFBA68C8), height: 0),
              // IPD
              Row(
                children: [
                  Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(8), child: const Center(child: Text('IPD', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_ipd1))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(_ipd2))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(TextEditingController(), hint: ''))),
                  Expanded(flex: 2, child: Center(child: _buildEyeCell(TextEditingController(), hint: ''))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? prefix,
    Widget? suffix,
    bool readOnly = false,
    void Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            prefixIcon: prefix,
            suffixIcon: suffix,
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        backgroundColor: const Color(0xFFBA68C8),
        title: const Text('Add Prescription/Order', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: _buildSerialBadge()),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _loadingSerial && _serialNo == 0
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFBA68C8)))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Person Name',
                  controller: _nameController,
                  hint: 'Full name',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter name' : null,
                  prefix: const Icon(Icons.person),
                ),
                spacing,
                _buildTextField(
                  label: 'Contact Number',
                  controller: _contactController,
                  hint: '03XXXXXXXXX',
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter contact number' : null,
                  prefix: const Icon(Icons.phone),
                ),
                spacing,
                const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBA68C8))),
                Row(
                  children: [
                    Expanded(child: RadioListTile<String>(title: const Text('Male'), value: 'Male', groupValue: _gender, onChanged: (val) => setState(() => _gender = val ?? 'Male'))),
                    Expanded(child: RadioListTile<String>(title: const Text('Female'), value: 'Female', groupValue: _gender, onChanged: (val) => setState(() => _gender = val ?? 'Female'))),
                  ],
                ),
                spacing,
                _buildEyeTable(),
                spacing,
                _buildTextField(label: 'Frame Details', controller: _frameController, hint: 'raybin-grey', prefix: const Icon(Icons.check_box)),
                spacing,
                _buildTextField(label: 'Lens Details', controller: _lensController, hint: 'Lens description'),
                spacing,
                _buildTextField(label: 'Remarks', controller: _remarksController, hint: 'Any remarks', maxLines: 3),
                spacing,
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(label: 'Total Amount', controller: _totalController, hint: '0.00', keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter total' : null, prefix: const Icon(Icons.attach_money)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(label: 'Advance Payment', controller: _advanceController, hint: '0.00', keyboardType: TextInputType.numberWithOptions(decimal: true), prefix: const Icon(Icons.money_off)),
                    ),
                  ],
                ),
                spacing,
                _buildTextField(label: 'Balance', controller: _balanceController, hint: 'Calculated automatically', keyboardType: TextInputType.numberWithOptions(decimal: true), readOnly: true, prefix: const Icon(Icons.account_balance_wallet)),
                spacing,
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(label: 'Date', controller: TextEditingController(text: _formatDate(_selectedDate)), readOnly: true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickDueDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(label: 'Due Date', controller: TextEditingController(text: _dueDate == null ? '' : _formatDate(_dueDate!)), readOnly: true),
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
                      backgroundColor: const Color(0xFFBA68C8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _submitting
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)),
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
