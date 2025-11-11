import 'package:flutter/material.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  int _step = 0;

  final _applicantNameCtrl = TextEditingController();
  DateTime? _applicantDob;
  String? _applicantGender; // 'Male' or 'Female'
  final _applicantMobileCtrl = TextEditingController();
  final _applicantFatherNameCtrl = TextEditingController();
  final _applicantBankNameCtrl = TextEditingController();
  final _applicantNicCtrl = TextEditingController();
  final _applicantAcctNoCtrl = TextEditingController();
  final List<String> _subtribes = const [
    'Hakim khil',
    'Baik Muhammad',
    'Shahi Khil',
    'langar khil',
    'Darwaiz',
    'Jalal',
    'Gulsher',
    'Walikhil',
  ];
  String? _applicantSubtribe;

  // Family Info
  String _relation = 'Son'; // W/D/S of
  String _familyName = '';
  DateTime? _familyDob;
  String? _familyGender; // auto from relation
  String _familyNic = '';
  bool _married = false; // married/unmarried
  String? _familySubtribe;
  double? _familySharePercent; // auto by gender + age

  final List<Map<String, dynamic>> _familyMembers = [];

  @override
  void dispose() {
    _applicantNameCtrl.dispose();
    _applicantMobileCtrl.dispose();
    _applicantFatherNameCtrl.dispose();
    _applicantBankNameCtrl.dispose();
    _applicantNicCtrl.dispose();
    _applicantAcctNoCtrl.dispose();
    super.dispose();
  }

  int _ageFromDob(DateTime? dob) {
    if (dob == null) return 0;
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  void _updateFamilyGenderFromRelation() {
    if (_relation == 'Son') {
      _familyGender = 'Male';
    } else {
      _familyGender = 'Female';
    }
  }

  void _updateFamilyShare() {
    final age = _ageFromDob(_familyDob);
    if (_familyGender == 'Male' && age >= 18) {
      _familySharePercent = 30;
    } else if (age < 18) {
      _familySharePercent = 5;
    } else if (_familyGender == 'Female' && age >= 18) {
      _familySharePercent = 15;
    } else {
      _familySharePercent = null;
    }
  }

  Widget _buildLocationDefaults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Province'),
        const SizedBox(height: 6),
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'KPK',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        const Text('District'),
        const SizedBox(height: 6),
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Kurram',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Tehsil'),
        const SizedBox(height: 6),
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Central',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Tribe'),
        const SizedBox(height: 6),
        const TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Khwajak/Parachamkani',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isApplicant}) async {
    final init = DateTime(2000, 1, 1);
    final first = DateTime(1900);
    final last = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() {
        if (isApplicant) {
          _applicantDob = picked;
        } else {
          _familyDob = picked;
          _updateFamilyShare();
        }
      });
    }
  }

  Widget _buildApplicantForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              const Text('Applicant image'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Applicant name'),
          const SizedBox(height: 6),
          TextField(
            controller: _applicantNameCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('DOB'),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _pickDate(isApplicant: true),
            child: InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: Text(
                _applicantDob == null
                    ? 'Select date'
                    : '${_applicantDob!.year}-${_applicantDob!.month.toString().padLeft(2, '0')}-${_applicantDob!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Gender'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _applicantGender,
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
            ],
            onChanged: (v) => setState(() => _applicantGender = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('Mobile number'),
          const SizedBox(height: 6),
          TextField(
            keyboardType: TextInputType.phone,
            controller: _applicantMobileCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('father name'),
          const SizedBox(height: 6),
          TextField(
            controller: _applicantFatherNameCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('Bank name'),
          const SizedBox(height: 6),
          TextField(
            controller: _applicantBankNameCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('Nic number'),
          const SizedBox(height: 6),
          TextField(
            controller: _applicantNicCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('Acct no'),
          const SizedBox(height: 6),
          TextField(
            controller: _applicantAcctNoCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          _buildLocationDefaults(),
          const SizedBox(height: 12),
          const Text('Subtribe'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _applicantSubtribe,
            items: _subtribes
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _applicantSubtribe = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _step = 1;
                });
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyForm() {
    _updateFamilyGenderFromRelation();
    _updateFamilyShare();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('W/D/S of'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _relation,
            items: const [
              DropdownMenuItem(value: 'Wife', child: Text('Wife')),
              DropdownMenuItem(value: 'Daughter', child: Text('Daughter')),
              DropdownMenuItem(value: 'Son', child: Text('Son')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _relation = v;
                _updateFamilyGenderFromRelation();
                _updateFamilyShare();
              });
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('Name'),
          const SizedBox(height: 6),
          TextField(
            onChanged: (v) => _familyName = v,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('Gender (auto)'),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(text: _familyGender ?? ''),
            enabled: false,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('DoB'),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              await _pickDate(isApplicant: false);
              setState(() {
                _updateFamilyShare();
              });
            },
            child: InputDecorator(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              child: Text(
                _familyDob == null
                    ? 'Select date'
                    : '${_familyDob!.year}-${_familyDob!.month.toString().padLeft(2, '0')}-${_familyDob!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('NIC'),
          const SizedBox(height: 6),
          TextField(
            onChanged: (v) => _familyNic = v,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('Share in percentage (auto)'),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(
                text: _familySharePercent == null
                    ? ''
                    : _familySharePercent!.toStringAsFixed(0)),
            enabled: false,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('M status'),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: _married,
                onChanged: (v) => setState(() => _married = v ?? false),
              ),
              const Text('married'),
              const SizedBox(width: 16),
              Checkbox(
                value: !_married,
                onChanged: (v) => setState(() => _married = !(v ?? false)),
              ),
              const Text('unmarried'),
            ],
          ),
          const SizedBox(height: 12),
          _buildLocationDefaults(),
          const SizedBox(height: 12),
          const Text('Subtribe'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _familySubtribe,
            items: _subtribes
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _familySubtribe = v),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (_familyName.isEmpty || _familyDob == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please complete family member details')), 
                      );
                      return;
                    }
                    setState(() {
                      _familyMembers.add({
                        'relation': _relation,
                        'name': _familyName,
                        'gender': _familyGender,
                        'dob': _familyDob,
                        'nic': _familyNic,
                        'married': _married,
                        'subtribe': _familySubtribe,
                        'share': _familySharePercent,
                      });
                      _relation = 'Son';
                      _familyName = '';
                      _familyDob = null;
                      _familyNic = '';
                      _married = false;
                      _familySubtribe = null;
                      _familySharePercent = null;
                      _updateFamilyGenderFromRelation();
                    });
                  },
                  child: const Text('Add another'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved')), 
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_familyMembers.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Added family members'),
                const SizedBox(height: 8),
                ..._familyMembers.map((m) => Card(
                      child: ListTile(
                        title: Text('${m['name']} (${m['relation']})'),
                        subtitle: Text('Gender: ${m['gender']}, Share: ${m['share'] ?? '-'}%'),
                      ),
                    )),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration form')),
      body: IndexedStack(
        index: _step,
        children: [
          _buildApplicantForm(),
          _buildFamilyForm(),
        ],
      ),
    );
  }
}
