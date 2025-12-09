import 'package:flutter/material.dart';
import '../Service/DoctorDBLayer.dart';

class DoctorProfileOnboarding extends StatefulWidget {
  const DoctorProfileOnboarding({super.key});

  @override
  State<DoctorProfileOnboarding> createState() =>
      _DoctorProfileOnboardingState();
}

class _DoctorProfileOnboardingState extends State<DoctorProfileOnboarding> {
  final _formKey = GlobalKey<FormState>();
  final _db = DoctorDBLayer();

  final _specialization = TextEditingController();
  final _licenseNumber = TextEditingController();
  final _yearsExperience = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _clinicAddress = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _specialization.dispose();
    _licenseNumber.dispose();
    _yearsExperience.dispose();
    _phone.dispose();
    _bio.dispose();
    _clinicAddress.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final payload = {
      'specialization': _specialization.text.trim(),
      'license_number': _licenseNumber.text.trim(),
      'years_experience': int.tryParse(_yearsExperience.text.trim()) ?? 0,
      'phone': _phone.text.trim(),
      'bio': _bio.text.trim(),
      'clinic_address': _clinicAddress.text.trim(),
    };
    try {
      final res = await _db.ensureDoctorProfile(payload);
      if (res != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/doctor_home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about your practice',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialization,
                decoration: const InputDecoration(labelText: 'Specialization'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _licenseNumber,
                decoration: const InputDecoration(labelText: 'License Number'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _yearsExperience,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                ),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _clinicAddress,
                decoration: const InputDecoration(labelText: 'Clinic Address'),
              ),
              TextFormField(
                controller: _bio,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const CircularProgressIndicator()
                      : const Text('Save and Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
