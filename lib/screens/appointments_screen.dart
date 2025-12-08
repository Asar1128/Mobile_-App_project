import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Service/SupabaseService.dart';
import '../Service/AppointmentDBLayer.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _layer = AppointmentDBLayer(SupabaseService.instance.client);
  bool _loading = true;
  String? _patientId;
  String? _hospitalId;
  List<Map<String, dynamic>> _appts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final client = SupabaseService.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) {
        setState(() {
          _loading = false;
        });
        return;
      }
      final p = await client
          .from('patients')
          .select('id,hospital_id')
          .eq('user_id', uid)
          .maybeSingle();
      if (p == null) {
        setState(() {
          _loading = false;
        });
        return;
      }
      final pid = p['id'] as String;
      final hid = p['hospital_id'] as String?;
      final list = await _layer.getPatientAppointments(pid);
      setState(() {
        _patientId = pid;
        _hospitalId = hid;
        _appts = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _loading = false);
    }
  }

  Future<void> _bookNew() async {
    if (_patientId == null || _hospitalId == null) return;
    final client = SupabaseService.instance.client;
    try {
      final docs = await client
          .from('doctors')
          .select('id, user:users(full_name)')
          .eq('hospital_id', _hospitalId)
          .order('id');
      final List<Map<String, dynamic>> doctors = (docs as List)
          .cast<Map<String, dynamic>>();
      if (doctors.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No doctors found in your hospital')),
        );
        return;
      }

      String? selectedDoctorId = doctors.first['id'] as String;
      DateTime selectedDateTime = DateTime.now().add(const Duration(days: 2));

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setSheet) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Appointment',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedDoctorId,
                      items: doctors
                          .map(
                            (d) => DropdownMenuItem<String>(
                              value: d['id'] as String,
                              child: Text(
                                (d['user']?['full_name'] as String?) ??
                                    d['id'] as String,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setSheet(() => selectedDoctorId = v),
                      decoration: const InputDecoration(
                        labelText: 'Doctor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              DateFormat(
                                'EEE, MMM d, y',
                              ).format(selectedDateTime),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDateTime,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null)
                                setSheet(
                                  () => selectedDateTime = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    selectedDateTime.hour,
                                    selectedDateTime.minute,
                                  ),
                                );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.schedule),
                            label: Text(
                              DateFormat('h:mm a').format(selectedDateTime),
                            ),
                            onPressed: () async {
                              final t = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay.fromDateTime(
                                  selectedDateTime,
                                ),
                              );
                              if (t != null)
                                setSheet(
                                  () => selectedDateTime = DateTime(
                                    selectedDateTime.year,
                                    selectedDateTime.month,
                                    selectedDateTime.day,
                                    t.hour,
                                    t.minute,
                                  ),
                                );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedDoctorId == null) return;
                          try {
                            final uid = client.auth.currentUser!.id;
                            await _layer.requestAppointment(
                              patientId: _patientId!,
                              doctorId: selectedDoctorId!,
                              hospitalId: _hospitalId!,
                              scheduledAt: selectedDateTime,
                              createdByUserId: uid,
                            );
                            if (context.mounted) Navigator.of(ctx).pop();
                            await _load();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Appointment requested'),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00ACC1),
                        ),
                        child: const Text(
                          'Request Appointment',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading doctors: $e')));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange.shade700;
      case 'approved':
        return Colors.blue.shade600;
      case 'rescheduled':
        return Colors.deepPurple.shade400;
      case 'completed':
        return Colors.green.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Future<void> _reschedule(Map<String, dynamic> appt) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(appt['scheduled_at'] ?? '') ??
          DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (newDate == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final dt = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      time.hour,
      time.minute,
    );
    try {
      final uid = SupabaseService.instance.client.auth.currentUser!.id;
      await _layer.rescheduleByPatient(
        appointmentId: appt['id'] as String,
        newDate: dt,
        actorUserId: uid,
        originalScheduledAt: DateTime.parse(appt['scheduled_at'] as String),
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reschedule requested')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Reschedule failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7FCFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: (_patientId != null)
          ? FloatingActionButton(
              onPressed: _bookNew,
              backgroundColor: const Color(0xFF00ACC1),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_appts.isEmpty)
          ? const Center(child: Text('No appointments found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _appts.length,
              itemBuilder: (context, i) {
                final a = _appts[i];
                final scheduled =
                    DateTime.tryParse(a['scheduled_at'] ?? '') ??
                    DateTime.now();
                final status = a['status'] as String;
                final canReschedule =
                    scheduled.difference(DateTime.now()).inHours > 24;
                return Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'EEE, MMM d, y • h:mm a',
                            ).format(scheduled),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(status),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _statusColor(status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor: ${a['doctor_id']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (canReschedule)
                            TextButton.icon(
                              onPressed: () => _reschedule(a),
                              icon: const Icon(
                                Icons.schedule,
                                color: Color(0xFF00ACC1),
                              ),
                              label: const Text('Reschedule'),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
