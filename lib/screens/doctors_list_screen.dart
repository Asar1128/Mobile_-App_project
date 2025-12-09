import 'package:flutter/material.dart';
import '../Service/SupabaseService.dart';
import 'appointment_booking_screen.dart';
import 'package:hospital_management_system/Model_Classes/doctor.dart';
import 'package:hospital_management_system/Model_Classes/hospital.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  List<Map<String, dynamic>> _doctors = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() => _loading = true);
    try {
      final client = SupabaseService.instance.client;
      final uid = client.auth.currentUser?.id;
      debugPrint('[DoctorsList] current user id: ' + (uid ?? 'null'));
      final res = await client
          .from('doctors')
          .select(
            'id, specialization, hospital_id, user:users(id,full_name,email)',
          )
          .order('id');

      debugPrint('[DoctorsList] result type: ' + res.runtimeType.toString());
      final list = (res as List).cast<Map<String, dynamic>>();
      debugPrint('[DoctorsList] fetched count: ' + list.length.toString());
      if (list.isNotEmpty) {
        debugPrint('[DoctorsList] first row sample: ' + list.first.toString());
      }

      _doctors = list;
      setState(() {});
    } catch (e) {
      debugPrint('[DoctorsList] fetch error: ' + e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load doctors: ' + e.toString())),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        title: const Text(
          'Find a Doctor',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7FCFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(context),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchDoctors,
                    child: _doctors.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(32),
                            children: const [
                              Center(child: Text('No doctors found')),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            itemCount: _doctors.length,
                            itemBuilder: (context, index) {
                              final d = _doctors[index];
                              return _DoctorListCard(
                                name:
                                    'Dr. ' +
                                    (d['user']?['full_name'] ?? 'Unknown'),
                                specialization:
                                    d['specialization'] ?? 'General',
                                experienceYears: 5,
                                consultationFee: '1000',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AppointmentBookingScreen(
                                        doctor: Doctor(
                                          doctorId: d['id'],
                                          userId: d['user']?['id'] ?? '',
                                          email: d['user']?['email'] ?? '',
                                          passwordHash: '',
                                          fullName:
                                              d['user']?['full_name'] ??
                                              'Unknown',
                                          phoneNumber: '',
                                          createdAt: DateTime.now(),
                                          specialization:
                                              d['specialization'] ?? 'General',
                                          qualification: 'MBBS',
                                          experienceYears: 5,
                                          licenseNumber: 'N/A',
                                          hospital: Hospital(
                                            hospitalId: d['hospital_id'] ?? '',
                                            hospitalName: 'Hospital',
                                            address: 'Unknown',
                                            city: 'Unknown',
                                            phoneNumber: '',
                                            email: '',
                                            licenseNumber: '',
                                          ),
                                          availableDays: const ['Mon', 'Tue'],
                                          consultationFee: '1000',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search doctors',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        // Optionally implement client-side filtering
      },
    );
  }
}

class _DoctorListCard extends StatelessWidget {
  final String name;
  final String specialization;
  final int experienceYears;
  final String consultationFee;
  final VoidCallback onTap;

  const _DoctorListCard({
    super.key,
    required this.name,
    required this.specialization,
    required this.experienceYears,
    required this.consultationFee,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                'https://images.unsplash.com/photo-1612348310065-2747124f5a34?q=80&w=60&h=60&fit=crop',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialization,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00ACC1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$experienceYears Years Exp.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4DD0E1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Fee: \$$consultationFee',
                style: const TextStyle(
                  color: Color(0xFF00ACC1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
