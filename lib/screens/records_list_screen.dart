import 'package:flutter/material.dart';
import 'package:hospital_management_system/utils/dummy_data.dart';
import 'package:hospital_management_system/Model_Classes/medical_record.dart'; 
import 'package:intl/intl.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        title: const Text('Medical Records', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF7FCFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        // === Using Dummy Data List ===
        children: dummyRecords.map((record) {
          final patient = dummyPatients.firstWhere(
              (p) => p.patientId == record.patientId,
              orElse: () => dummyPatients.first);

          return _RecordCard(
            record: record,
            patientName: patient.fullName,
          );
        }).toList(),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final record;
  final String patientName;

  const _RecordCard({required this.record, required this.patientName});

  Color _getTypeColor() {
    switch (record.testType) {
      case TestType.bloodTest:
        return Colors.red.shade400;
      case TestType.xray:
        return Colors.blue.shade400;
      case TestType.mri:
        return Colors.deepPurple.shade400;
      case TestType.ctScan:
        return Colors.indigo.shade400;
      case TestType.ecg:
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to Record Detail Screen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing Record Details for ${record.recordId}')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border(left: BorderSide(color: _getTypeColor(), width: 6)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00ACC1).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.testType.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor()),
                ),
                Text(
                  'Result Date: ${DateFormat('MMM d, y').format(record.resultDate)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              'Patient: $patientName',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Details: ${record.testDetails}',
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Results: ${record.results}',
                style: TextStyle(fontSize: 14, color: Colors.green.shade800, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}