import 'package:flutter/material.dart';
import 'package:hospital_management_system/utils/dummy_data.dart';
import 'package:hospital_management_system/screens/staff_list_screen.dart'; 
import 'package:hospital_management_system/Model_Classes/hospital.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hospital = dummyHospital; // === Using Dummy Data Object ===

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        title: Text(hospital.hospitalName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF7FCFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(context, hospital),
            const SizedBox(height: 30),

            // Key Actions
            const Text('Management Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _buildActionTile(context, 'Manage Staff', Icons.group, Colors.orange.shade400, () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StaffListScreen()));
                }),
                _buildActionTile(context, 'Reports', Icons.analytics_outlined, Colors.purple.shade400, () {}),
                _buildActionTile(context, 'Settings', Icons.settings, Colors.blueGrey.shade400, () {}),
              ],
            ),
            const SizedBox(height: 30),

            // Contact Info
            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            _buildInfoTile(Icons.location_on_outlined, 'Address', '${hospital.address}, ${hospital.city}'),
            _buildInfoTile(Icons.phone_outlined, 'Phone', hospital.phoneNumber),
            _buildInfoTile(Icons.email_outlined, 'Email', hospital.email),
            _buildInfoTile(Icons.verified_user_outlined, 'License', hospital.licenseNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Hospital hospital) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF00ACC1),
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00ACC1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.apartment, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            hospital.hospitalName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Hospital ID: ${hospital.hospitalId}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 32, // Responsive width
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00ACC1)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}