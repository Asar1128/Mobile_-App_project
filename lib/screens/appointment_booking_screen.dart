import 'package:flutter/material.dart';
import 'package:hospital_management_system/Model_Classes/doctor.dart';
// === FIX: Explicitly import Patient model for BloodGroup enum ===
import 'package:hospital_management_system/Model_Classes/patient.dart';
import 'package:intl/intl.dart';
import '../Service/SupabaseService.dart';
import '../Service/AppointmentDBLayer.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final Doctor doctor;

  const AppointmentBookingScreen({super.key, required this.doctor});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _problemCtrl = TextEditingController();

  // Form State Variables
  String? _selectedGender;
  BloodGroup? _selectedBloodGroup; // BloodGroup is now correctly referenced

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _mobileCtrl.dispose();
    _problemCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submitAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _selectedBloodGroup != null) {
      try {
        final client = SupabaseService.instance.client;
        final user = client.auth.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Not logged in')));
          return;
        }

        // Resolve patient and hospital for current user
        final p = await client
            .from('patients')
            .select('id, hospital_id')
            .eq('user_id', user.id)
            .maybeSingle();
        if (p == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient profile not found')),
          );
          return;
        }
        final patientId = p['id'] as String;
        final hospitalId = p['hospital_id'] as String?;
        if (hospitalId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hospital not linked to patient')),
          );
          return;
        }

        // Choose a tentative schedule (next 2 days at 10:00am) — can be rescheduled
        final now = DateTime.now();
        final scheduledAt = DateTime(now.year, now.month, now.day + 2, 10, 0);

        // Persist appointment request
        final layer = AppointmentDBLayer(client);
        await layer.requestAppointment(
          patientId: patientId,
          doctorId: widget.doctor.doctorId,
          hospitalId: hospitalId,
          scheduledAt: scheduledAt,
          createdByUserId: user.id,
        );

        // Optionally: store chief complaint in a note field if supported by schema
        // If not available, this remains as a future enhancement.

        // Navigate to Appointments to show all patient appointments
        if (!mounted) return;
        Navigator.of(context).pushNamed('/appointments');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create appointment: $e')),
        );
      }
    } else if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender.')),
      );
    } else if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your blood group.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Step 1 of 3: Enter Patient Details',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Patient Name
              _buildInputField(
                controller: _nameCtrl,
                hintText: 'Enter your Name',
                label: 'Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Date of Birth
              _buildDateField(
                controller: _dobCtrl,
                label: 'Date of Birth',
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 20),

              // Mobile Number
              _buildInputField(
                controller: _mobileCtrl,
                hintText: 'Enter your Number',
                label: 'Mobile Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Blood Group Selection
              _buildBloodGroupSelector(),
              const SizedBox(height: 20),

              // Gender Selection
              _buildGenderSelector(),
              const SizedBox(height: 20),

              // Write Your Problem
              const Text(
                'Write your problem',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildProblemField(),
              const SizedBox(height: 40),

              // Continue Button
              _buildContinueButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Reusable Input Widgets ---

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF4DD0E1)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 10,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            prefixIcon: Icon(icon, color: const Color(0xFF4DD0E1)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 10,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your Date of Birth';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProblemField() {
    return TextFormField(
      controller: _problemCtrl,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Write briefly about your problem...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(15),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please describe your chief complaint.';
        }
        return null;
      },
    );
  }

  Widget _buildBloodGroupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Group',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: BloodGroup.values
              .map((bg) {
                final name = bg
                    .toString()
                    .split('.')
                    .last
                    .replaceAll('Positive', '+')
                    .replaceAll('Negative', '-');
                return GestureDetector(
                  onTap: () => setState(() => _selectedBloodGroup = bg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedBloodGroup == bg
                          ? const Color(0xFF00ACC1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedBloodGroup == bg
                            ? const Color(0xFF00ACC1)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: _selectedBloodGroup == bg
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              })
              .toList()
              .sublist(0, 4), // Showing only A+, A-, B+, B- for screen space
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(children: [_buildGenderRadio('Male'), _buildGenderRadio('Female')]),
      ],
    );
  }

  Widget _buildGenderRadio(String gender) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: gender,
          groupValue: _selectedGender,
          onChanged: (String? value) {
            setState(() {
              _selectedGender = value;
            });
          },
          activeColor: const Color(0xFF00ACC1),
        ),
        Text(gender, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00ACC1).withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _submitAppointment,
        child: const Text(
          'Continue >',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
