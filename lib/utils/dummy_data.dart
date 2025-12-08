// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:hospital_management_system/Model_Classes/appointment.dart';
import 'package:hospital_management_system/Model_Classes/doctor.dart';
import 'package:hospital_management_system/Model_Classes/patient.dart';
import 'package:hospital_management_system/Model_Classes/hospital.dart';
import 'package:hospital_management_system/Model_Classes/medical_record.dart';
import 'package:hospital_management_system/Model_Classes/medicine.dart';
import 'package:hospital_management_system/Model_Classes/prescription.dart';

// --- Shared Utility Functions ---

// Function to generate a simple, random Hospital object
Hospital getDummyHospital() {
  return Hospital(
    hospitalId: 'H101',
    hospitalName: 'MediChain Central',
    address: '123 Main St',
    city: 'New York',
    phoneNumber: '555-1234',
    email: 'contact@medichain.com',
    licenseNumber: 'L123456',
  );
}

// Function to generate a random Doctor (FIXED SYNTAX)
Doctor getDummyDoctor(
  String name,
  String specialization,
  String fee,
  int exp,
  String image,
) {
  // Use local variables for reusable IDs within the constructor
  final String uniqueUserId = 'U${DateTime.now().millisecondsSinceEpoch}';
  final String uniqueDoctorId =
      'DR${DateTime.now().millisecondsSinceEpoch + 1}';

  return Doctor(
    // 1. Doctor specific required fields
    doctorId: uniqueDoctorId,
    specialization: specialization,
    qualification: 'MD, PhD',
    experienceYears: exp,
    licenseNumber: 'MDL-9876',
    hospital: getDummyHospital(),
    availableDays: ['Mon', 'Wed', 'Fri'],
    consultationFee: fee,

    // 2. Inherited User required fields
    userId: uniqueUserId,
    email: 'dr.${name.toLowerCase().replaceAll(' ', '')}@medichain.com',
    passwordHash: 'hashedpassword',
    fullName: name,
    phoneNumber: '555-DR',
    createdAt: DateTime.now(),
  );
}

// --- Dummy Data Lists (10+ items each) ---

final Hospital dummyHospital = getDummyHospital();

final List<Doctor> dummyDoctors = [
  getDummyDoctor(
    'Sarah Wilson',
    'Cardiologist',
    '150',
    15,
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'Robert Davis',
    'Neurologist',
    '200',
    8,
    'https://images.unsplash.com/photo-1559839734-2b71f90a6119?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'Emily Chen',
    'Pediatrician',
    '120',
    5,
    'https://images.unsplash.com/photo-1594824476967-46369d251e60?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'Marcus Jones',
    'Orthopedic',
    '180',
    22,
    'https://images.unsplash.com/photo-1612531384649-ad021b36e788?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'Laura Kim',
    'Dermatologist',
    '100',
    10,
    'https://images.unsplash.com/photo-1582755291244-672580436d54?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'Omar Hassan',
    'General Surgeon',
    '250',
    25,
    'https://images.unsplash.com/photo-1612348310065-2747124f5a34?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'Nina Rodriguez',
    'Oncologist',
    '300',
    18,
    'https://images.unsplash.com/photo-1550831107-1552a4c14828?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'David Lee',
    'Psychiatrist',
    '160',
    7,
    'https://images.unsplash.com/photo-1576092508191-ef1244d56f5c?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'Jessica Wu',
    'Ophthalmologist',
    '130',
    12,
    'https://images.unsplash.com/photo-1594824476967-46369d251e60?q=80&w=150&h=150&fit=crop',
  ),
  getDummyDoctor(
    'Kevin Hall',
    'Urologist',
    '190',
    9,
    'https://images.unsplash.com/photo-1612348310065-2747124f5a34?q=80&w=150&h=150&fit=crop',
  ),
];

// ... (Rest of the dummy data lists remain unchanged) ...

final List<Patient> dummyPatients = List.generate(12, (index) {
  return Patient(
    patientId: 'P${100 + index}',
    userId: 'UP${100 + index}',
    email: 'patient${index + 1}@example.com',
    passwordHash: 'pwhash',
    fullName: (index % 2 == 0) ? 'John Doe $index' : 'Alice Smith $index',
    phoneNumber: '555-10${index + 1}',
    createdAt: DateTime.now().subtract(Duration(days: 300 - index * 10)),
    dateOfBirth: DateTime(1985 + index, 5, 15),
    gender: (index % 2 == 0) ? 'Male' : 'Female',
    bloodGroup: (index % 3 == 0) ? BloodGroup.OPositive : BloodGroup.ANegative,
    address: '456 Oak Ave ${index}',
    emergencyContactName: 'Contact ${index}',
    emergencyContactPhone: '555-90${index}',
    hospital: dummyHospital,
    assignedDoctorId: dummyDoctors[index % 10].doctorId,
    medicalRecords: [],
    registrationDate: DateTime.now().subtract(Duration(days: 300 - index * 10)),
    allergies: (index % 5 == 0) ? 'Peanuts' : null,
  );
});

final List<Appointment> dummyAppointments = List.generate(10, (index) {
  return Appointment(
    appointmentId: 'A${100 + index}',
    patientId: dummyPatients[index].patientId,
    doctorId: dummyDoctors[index % 10].doctorId,
    appointmentDate: DateTime.now().add(Duration(days: index - 5)),
    timeSlot: '${9 + index}:00 AM',
    reason: (index % 3 == 0)
        ? 'Annual checkup'
        : 'Specific illness consultation',
    status: (index < 5)
        ? AppointmentStatus.scheduled
        : AppointmentStatus.completed,
    createdAt: DateTime.now(),
  );
});

final List<MedicalRecord> dummyRecords = List.generate(15, (index) {
  final patient = dummyPatients[index % 12];
  return MedicalRecord(
    recordId: 'MR${100 + index}',
    patientId: patient.patientId,
    testType: TestType.values[index % TestType.values.length],
    sampleDate: DateTime.now().subtract(Duration(days: 30 - index)),
    resultDate: DateTime.now().subtract(Duration(days: 28 - index)),
    testDetails: 'Detailed analysis for ${patient.fullName}',
    results: (index % 4 == 0) ? 'Abnormal findings' : 'Within normal range',
    conductedBy: 'Lab Tech ${index % 5}',
    attachmentUrls: ['https://example.com/report${index}.pdf'],
    notes: 'Follow-up recommended in two weeks.',
  );
});

final List<Prescription> dummyPrescriptions = List.generate(5, (index) {
  return Prescription(
    prescriptionId: 'Psc${100 + index}',
    patientId: dummyPatients[index].patientId,
    doctorId: dummyDoctors[index % 10].doctorId,
    prescriptionDate: DateTime.now().subtract(Duration(days: index * 2)),
    diagnosis: (index % 2 == 0) ? 'Hypertension' : 'Seasonal Allergy',
    medicines: [
      Medicine(
        medicineName: 'Medication A',
        dosage: '10mg',
        frequency: 'OD',
        durationDays: 30,
        instructions: 'Take in the morning.',
      ),
      Medicine(
        medicineName: 'Medication B',
        dosage: '500mg',
        frequency: 'TDS',
        durationDays: 7,
        instructions: 'Take after food.',
      ),
    ],
    additionalNotes: 'Strict diet required.',
    followUpDate: DateTime.now().add(const Duration(days: 30)),
  );
});
