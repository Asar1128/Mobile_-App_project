import 'package:flutter/material.dart';
import '../Service/DoctorDBLayer.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final _db = DoctorDBLayer();
  List<Map<String, dynamic>> _patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final patients = await _db.listDoctorPatients();
      setState(() {
        _patients = patients;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Dashboard')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [_buildPatientsSection()],
        ),
      ),
    );
  }

  Widget _buildPatientsSection() {
    return _cardShell(
      'My Patients',
      _loading
          ? const Text('Loading...')
          : Column(
              children: _patients.map((p) {
                final name = p['user']?['full_name'] ?? 'Patient';
                return Column(
                  children: [
                    ListTile(
                      title: Text(name),
                      subtitle: const Text('Your patient'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Records'),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/records',
                                arguments: {'patientId': p['id']},
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('Prescriptions'),
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/prescriptions',
                                arguments: {'patientId': p['id']},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _cardShell(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
