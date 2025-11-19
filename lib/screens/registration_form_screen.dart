import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/services/registration_service.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  int _step = 0;
  bool _isLoading = false;
  bool _isLoadingCNIC = true;
  bool _isUploadingImage = false;
  File? _applicantImage;
  String? _imageUrl;

  final _applicantNameCtrl = TextEditingController();
  DateTime? _applicantDob;
  String? _applicantGender; // 'Male' or 'Female'
  final _applicantMobileCtrl = TextEditingController();
  final _applicantFatherNameCtrl = TextEditingController();
  final _applicantBankNameCtrl = TextEditingController();
  final _applicantNicCtrl = TextEditingController();
  final _applicantAcctNoCtrl = TextEditingController();

  final RegistrationService _registrationService = RegistrationService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
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
  double? _applicantSharePercent; // auto by gender + age

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
  void initState() {
    super.initState();
    _loadUserCNIC();
  }

  Future<void> _loadUserCNIC() async {
    try {
      final cnic = await _registrationService.getUserCNIC();
      if (mounted) {
        setState(() {
          if (cnic != null) {
            _applicantNicCtrl.text = cnic;
          }
          _isLoadingCNIC = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCNIC = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (image != null) {
        setState(() {
          _applicantImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveApplicantData() async {
    if (_applicantNameCtrl.text.isEmpty ||
        _applicantDob == null ||
        _applicantGender == null ||
        _applicantMobileCtrl.text.isEmpty ||
        _applicantFatherNameCtrl.text.isEmpty ||
        _applicantBankNameCtrl.text.isEmpty ||
        _applicantNicCtrl.text.isEmpty ||
        _applicantAcctNoCtrl.text.isEmpty ||
        _applicantSubtribe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _step = 1;
    });
  }

  Future<void> _saveRegistrationData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // Upload image if selected
      if (_applicantImage != null) {
        bool dialogShown = false;
        // Show loading dialog for image upload
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Compressing and uploading image...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          dialogShown = true;
        }

        setState(() {
          _isUploadingImage = true;
        });

        try {
          final fileName = 'applicant_${DateTime.now().millisecondsSinceEpoch}.jpg';
          imageUrl = await _storageService.uploadImage(
            _applicantImage!,
            userId,
            fileName,
          );
        } catch (e) {
          if (mounted && dialogShown) {
            Navigator.of(context).pop(); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: ${e.toString()}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } finally {
          setState(() {
            _isUploadingImage = false;
          });
          // Close loading dialog if still open
          if (mounted && dialogShown && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      }

      // Calculate applicant share before saving
      _updateApplicantShare();

      // Prepare applicant data
      final applicantData = {
        'name': _applicantNameCtrl.text.trim(),
        'dob': _applicantDob!.toIso8601String(),
        'gender': _applicantGender,
        'mobile': _applicantMobileCtrl.text.trim(),
        'fatherName': _applicantFatherNameCtrl.text.trim(),
        'bankName': _applicantBankNameCtrl.text.trim(),
        'nic': _applicantNicCtrl.text.trim(),
        'accountNo': _applicantAcctNoCtrl.text.trim(),
        'subtribe': _applicantSubtribe,
        'share': _applicantSharePercent,
        'province': 'KPK',
        'district': 'Kurram',
        'tehsil': 'Central',
        'tribe': 'Khwajak/Parachamkani',
      };

      // Check if there's a family member in the form that hasn't been added yet
      // If the form has family member data, add it to the list before saving
      if (_familyName.isNotEmpty && _familyDob != null) {
        // Ensure gender is set based on relation
        _updateFamilyGenderFromRelation();
        _updateFamilyShare();
        
        // Check if this family member is already in the list
        bool alreadyAdded = _familyMembers.any((member) =>
            member['name'] == _familyName &&
            member['dob'] == _familyDob);
        
        if (!alreadyAdded) {
          _familyMembers.add({
            'relation': _relation,
            'name': _familyName,
            'gender': _familyGender,
            'dob': _familyDob,
            'nic': _familyNic,
            'married': _married,
            'subtribe': _familySubtribe,
            'share': _familySharePercent,
            'province': 'KPK',
            'district': 'Kurram',
            'tehsil': 'Central',
            'tribe': 'Khwajak/Parachamkani',
          });
        }
      }

      // Prepare family members data (convert DateTime to ISO string)
      final familyMembersData = _familyMembers.map((member) {
        final memberData = Map<String, dynamic>.from(member);
        if (memberData['dob'] is DateTime) {
          memberData['dob'] = (memberData['dob'] as DateTime).toIso8601String();
        }
        return memberData;
      }).toList();

      // Save to Firestore
      final result = await _registrationService.saveRegistrationData(
        applicantData: applicantData,
        familyMembers: familyMembersData,
        imageUrl: imageUrl,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration data saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Failed to save registration'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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

  void _updateApplicantShare() {
    final age = _ageFromDob(_applicantDob);
    if (_applicantGender == 'Male' && age >= 18) {
      _applicantSharePercent = 30;
    } else if (age < 18) {
      _applicantSharePercent = 5;
    } else if (_applicantGender == 'Female' && age >= 18) {
      _applicantSharePercent = 15;
    } else {
      _applicantSharePercent = null;
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
          _updateApplicantShare();
        } else {
          _familyDob = picked;
          _updateFamilyShare();
        }
      });
    }
  }

  Widget _buildApplicantForm() {
    _updateApplicantShare();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _applicantImage != null
                      ? FileImage(_applicantImage!)
                      : null,
                  child: _applicantImage == null
                      ? const Icon(Icons.camera_alt, size: 32)
                      : null,
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
            onChanged: (v) {
              setState(() {
                _applicantGender = v;
                _updateApplicantShare();
              });
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          const Text('Share in percentage (auto)'),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(
                text: _applicantSharePercent == null
                    ? ''
                    : _applicantSharePercent!.toStringAsFixed(0)),
            enabled: false,
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
          _isLoadingCNIC
              ? const TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Loading CNIC...',
                  ),
                )
              : TextField(
                  controller: _applicantNicCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'CNIC from your account',
                  ),
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
              onPressed: _saveApplicantData,
              child: const Text('Next: Add Family Members'),
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
                        'province': 'KPK',
                        'district': 'Kurram',
                        'tehsil': 'Central',
                        'tribe': 'Khwajak/Parachamkani',
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
                  onPressed: _isLoading ? null : _saveRegistrationData,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save Registration'),
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
