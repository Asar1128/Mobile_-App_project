import 'package:flutter/material.dart';
import 'package:hospital_management_system/utils/dummy_data.dart';
import 'package:hospital_management_system/Model_Classes/staff.dart'; 

class StaffListScreen extends StatelessWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: Staff list is defined here but uses the getDummyHospital helper from dummy_data.dart
    final List<Staff> dummyStaff = [
      Staff(
        staffId: 'S001',
        userId: 'US001',
        email: 'nurse1@medichain.com',
        passwordHash: 'pwhash',
        fullName: 'Brenda Lee (Nurse)',
        phoneNumber: '555-4001',
        createdAt: DateTime.now(),
        staffType: StaffType.nurse,
        department: 'ER',
        hospital: getDummyHospital(),
        shift: 'Day',
        joiningDate: DateTime(2018, 5, 1),
      ),
      Staff(
        staffId: 'S002',
        userId: 'US002',
        email: 'reception1@medichain.com',
        passwordHash: 'pwhash',
        fullName: 'David Chu (Receptionist)',
        phoneNumber: '555-4002',
        createdAt: DateTime.now(),
        staffType: StaffType.receptionist,
        department: 'Front Office',
        hospital: getDummyHospital(),
        shift: 'Evening',
        joiningDate: DateTime(2021, 1, 15),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        title: const Text('Staff Directory', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF7FCFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        // === Using Dummy Data List ===
        children: dummyStaff.map((staff) {
          return _StaffListCard(staff: staff);
        }).toList(),
      ),
    );
  }
}

class _StaffListCard extends StatelessWidget {
  final staff;

  const _StaffListCard({required this.staff});

  IconData _getIconForStaffType() {
    switch (staff.staffType) {
      case StaffType.nurse:
        return Icons.local_hospital;
      case StaffType.receptionist:
        return Icons.phone_in_talk;
      case StaffType.technician:
        return Icons.build;
      case StaffType.pharmacist:
        return Icons.medication;
      case StaffType.administrator:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to Staff Profile Detail
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing Profile for ${staff.fullName}')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00ACC1).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4DD0E1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getIconForStaffType(), color: const Color(0xFF00ACC1), size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.fullName,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${staff.department} - ${staff.staffType.toString().split('.').last}',
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                staff.shift,
                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}