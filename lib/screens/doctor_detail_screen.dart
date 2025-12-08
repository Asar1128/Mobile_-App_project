import 'package:flutter/material.dart';
import 'package:hospital_management_system/Model_Classes/doctor.dart';
// === FIX 2: Import the AppointmentBookingScreen ===
import 'appointment_booking_screen.dart'; 
import 'package:hospital_management_system/Model_Classes/patient.dart';


class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;
  
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    // Hardcoded demo data for attributes not in the Doctor class
    const patientCount = '1000+';
    const rating = '4.86';
    const List<String> specialties = ['Skin Hair', 'Allergy', 'STD'];
    const workingTime = 'Sat - Mon 10:30 AM - 06:00PM';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Profile Picture Section
            _buildProfileHeader(context, doctor),
            
            // 2. Details and Info
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  _buildStatsRow(patientCount, rating, doctor.experienceYears),
                  const SizedBox(height: 20),

                  // Specialties Section
                  const Text('Specialist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: specialties.map((s) => _buildSpecialtyChip(s)).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Working Time
                  const Text('Working time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    workingTime,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // About
                  const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  Text( 
                    'Dr. ${doctor.fullName} is a highly qualified ${doctor.specialization} with ${doctor.experienceYears} years of experience. ${doctor.qualification} from a renowned institution. Specializing in minor procedures and consultation.',
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // Booking Button
                  _buildBookingButton(context, doctor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(BuildContext context, Doctor doctor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // Doctor Image
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.network(
              'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=120&h=120&fit=crop', // Placeholder
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 15),
          // Name and Specialty
          Text(
            'Dr. ${doctor.fullName}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 5),
          Text(
            '${doctor.specialization} (${doctor.experienceYears} years experience)',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String patientCount, String rating, int exp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(Icons.group, patientCount, 'Patient'),
        _buildStatItem(Icons.star, rating, 'Rating'),
        _buildStatItem(Icons.work, '$exp yrs', 'Experience'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00ACC1), size: 20),
            const SizedBox(width: 5),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildSpecialtyChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4DD0E1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4DD0E1).withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF00ACC1), fontSize: 14),
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context, Doctor doctor) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4DD0E1),
            Color(0xFF00ACC1),
          ],
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
        onPressed: () {
          // Navigate to the Appointment Booking screen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => AppointmentBookingScreen(doctor: doctor)),
          );
        },
        child: const Text(
          'Book Appointment',
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