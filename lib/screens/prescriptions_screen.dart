import 'package:flutter/material.dart';
import 'package:hospital_management_system/utils/dummy_data.dart';
import 'package:intl/intl.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        title: const Text('Prescriptions', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF7FCFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        // === Using Dummy Data List ===
        children: dummyPrescriptions.map((prescription) {
          final patient = dummyPatients.firstWhere(
              (p) => p.patientId == prescription.patientId,
              orElse: () => dummyPatients.first);
          final doctor = dummyDoctors.firstWhere(
              (d) => d.doctorId == prescription.doctorId,
              orElse: () => dummyDoctors.first);

          return _PrescriptionCard(
            prescription: prescription,
            patientName: patient.fullName,
            doctorName: doctor.fullName,
          );
        }).toList(),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final prescription;
  final String patientName;
  final String doctorName;

  const _PrescriptionCard({
    required this.prescription,
    required this.patientName,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${prescription.prescriptionId}',
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                Text(
                  DateFormat('MMM d, y').format(prescription.prescriptionDate),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          // Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnosis: ${prescription.diagnosis}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00ACC1)),
                ),
                const SizedBox(height: 10),
                Text('Patient: $patientName', style: const TextStyle(fontSize: 15)),
                Text('Doctor: Dr. $doctorName', style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 15),
                const Text('Medicines:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...prescription.medicines.map<Widget>((med) => Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                  child: Text(
                    '• ${med.medicineName} (${med.dosage}, ${med.frequency}, ${med.durationDays} days)',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                )).toList(),
                const SizedBox(height: 15),
                if (prescription.followUpDate != null)
                  Text(
                    'Follow-up Date: ${DateFormat('MMM d, y').format(prescription.followUpDate)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700),
                  ),
              ],
            ),
          ),
          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print Prescription clicked')));
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View/Print', style: TextStyle(color: Color(0xFF00ACC1))),
                  SizedBox(width: 4),
                  Icon(Icons.print_outlined, size: 18, color: Color(0xFF00ACC1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}