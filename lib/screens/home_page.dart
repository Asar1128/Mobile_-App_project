import 'package:flutter/material.dart';
import 'package:hospital_management_system/utils/dummy_data.dart';
import '../Service/SupabaseService.dart';
import 'package:intl/intl.dart';
// Removed unused screen imports to fix lints
import 'package:hospital_management_system/widgets/app_drawer.dart'; // NEW IMPORT
import 'package:intl/intl.dart';
// (duplicate import removed)

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All possible services; we'll filter these based on role
  final List<Map<String, dynamic>> _allServices = [
    {
      'name': 'Appointments',
      'icon': Icons.calendar_today,
      'color': 'FFB74D',
      'route': '/appointments',
    },
    {
      'name': 'Doctors',
      'icon': Icons.medical_services,
      'color': '4DD0E1',
      'route': '/doctors',
    },
    {
      'name': 'Patients',
      'icon': Icons.people,
      'color': '81C784',
      'route': '/patients',
    },
    {
      'name': 'Records',
      'icon': Icons.folder_open,
      'color': '9575CD',
      'route': '/records',
    },
    {
      'name': 'Prescriptions',
      'icon': Icons.receipt_long,
      'color': 'F06292',
      'route': '/prescriptions',
    },
    {
      'name': 'Hospital Admin',
      'icon': Icons.apartment,
      'color': 'A1887F',
      'route': '/hospital_admin',
    },
  ];

  List<Map<String, dynamic>> _services = [];
  String? _role; // patient | doctor | staff | admin
  bool _loadingRole = true;

  // Use a global key to manage the Scaffold state (needed to open the drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // --- UI Helper Widgets ---

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '').replaceAll('0X', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (onViewAll != null)
            InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF00ACC1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredServicesForRole(String? role) {
    if (role == 'patient') {
      final allowed = {
        '/appointments',
        '/doctors',
        '/records',
        '/prescriptions',
      };
      return _allServices.where((s) => allowed.contains(s['route'])).toList();
    }
    // For other roles keep existing set for now.
    return _allServices;
  }

  Widget _buildServiceCategory(
    String name,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> item) {
    // ... (same as before) ...
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              item['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: Colors.red.shade100,
                child: const Center(
                  child: Icon(Icons.person, color: Colors.red),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  item['specialty'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00ACC1),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Upcoming Appointment Card (Prominent Card)
  Widget _buildUpcomingAppointmentCard(BuildContext context) {
    final client = SupabaseService.instance.client;
    final user = client.auth.currentUser;
    // If not logged in, show a gentle prompt
    if (user == null) {
      return _buildUpcomingCardShell(
        title: 'Upcoming Appointment',
        subtitle: 'Sign in to see your schedule',
        trailing: null,
      );
    }

    // Fetch the next upcoming appointment for this patient from DB.
    // Assumes a patients row exists linked by user_id.
    // We select the soonest future appointment.
    // Fallback: show a CTA to book.
    return FutureBuilder<List<dynamic>>(
      future: client
          .from('patients')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle()
          .then((p) async {
            if (p == null) return [];
            final pid = p['id'] as String;
            final rows = await client
                .from('appointments')
                .select(
                  'id, scheduled_at, doctor:doctors(id, specialization, user:users(id, full_name))',
                )
                .gte('scheduled_at', DateTime.now().toIso8601String())
                .eq('patient_id', pid)
                .order('scheduled_at', ascending: true)
                .limit(1);
            return rows as List<dynamic>;
          }),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _buildUpcomingCardShell(
            title: 'Upcoming Appointment',
            subtitle: 'Loading...',
            trailing: null,
          );
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return _buildUpcomingCardShell(
            title: 'Upcoming Appointment',
            subtitle: 'No upcoming appointments',
            trailing: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/doctors'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00ACC1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Book Now'),
            ),
          );
        }
        final appt = list.first as Map<String, dynamic>;
        final doctor = appt['doctor'] as Map<String, dynamic>?;
        final docUser = doctor?['user'] as Map<String, dynamic>?;
        final docName = docUser?['full_name'] ?? 'Doctor';
        final when = DateTime.parse(appt['scheduled_at'] as String);
        final subtitle = '${DateFormat('MMM d, h:mm a').format(when)}';
        return _buildUpcomingCardShell(
          title: 'Upcoming Appointment',
          subtitle: 'Dr. $docName · $subtitle',
          trailing: ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/appointments'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ACC1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('View All'),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingCardShell({
    required String title,
    required String subtitle,
    required Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4DD0E1).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DD0E1).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00ACC1),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 24.0;

    return Scaffold(
      key: _scaffoldKey, // Attach the key to the Scaffold
      backgroundColor: const Color(0xFFF7FCFF),

      // Add the AppDrawer
      drawer: const AppDrawer(),

      body: CustomScrollView(
        slivers: [
          // 1. Custom AppBar and Header
          SliverAppBar(
            backgroundColor: const Color(0xFFF7FCFF),
            floating: true,
            pinned: false,
            // Updated: Open the drawer when the menu icon is tapped
            leading: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                size: 28,
                color: Colors.black87,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: Colors.black87,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications clicked')),
                  );
                },
              ),
              const SizedBox(width: horizontalPadding / 2),
            ],
            toolbarHeight: 80,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: Column(
                  children: [
                    // Search Bar and Filter Button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                hintText:
                                    'Search by Doctor, Patient, or Service',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Filter Button (Blue Gradient)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00ACC1).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.filter_list,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Filter clicked')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Scrollable Content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loadingRole)
                      const Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: LinearProgressIndicator(),
                      ),
                    // --- Upcoming Appointment Card ---
                    _buildUpcomingAppointmentCard(context),

                    // --- Services Section (Main Navigation) ---
                    _buildSectionHeader('Services & Management'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _services.map((service) {
                        return _buildServiceCategory(
                          service['name'],
                          service['icon'],
                          _getColorFromHex(service['color']),
                          () {
                            // Responsive Navigation based on Model/Route
                            Navigator.of(context).pushNamed(service['route']);
                          },
                        );
                      }).toList(),
                    ),

                    // --- Popular Doctors Section ---
                    _buildSectionHeader(
                      'Popular Doctors',
                      onViewAll: () {
                        Navigator.of(context).pushNamed('/doctors');
                      },
                    ),
                    SizedBox(
                      height: 220,
                      child: _loadingDoctors
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _popularDoctors.length,
                              itemBuilder: (context, index) {
                                final doctor = _popularDoctors[index];
                                return InkWell(
                                  onTap: () {
                                    // Navigate to detailed doctor profile
                                    Navigator.of(context).pushNamed('/doctors');
                                  },
                                  child: _buildDoctorCard(doctor),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _services = _filteredServicesForRole(null);
    _loadRole();
    _fetchPopularDoctors();
  }

  List<Map<String, dynamic>> _popularDoctors = [];
  bool _loadingDoctors = false;

  Future<void> _fetchPopularDoctors() async {
    setState(() => _loadingDoctors = true);
    try {
      final client = SupabaseService.instance.client;
      final res = await client
          .from('doctors')
          .select('id, specialization, user:users(full_name)')
          .limit(10);
      final list = (res as List).cast<Map<String, dynamic>>();
      setState(() {
        _popularDoctors = list
            .map(
              (d) => {
                'name':
                    'Dr. ' +
                    ((d['user']?['full_name'] as String?) ?? 'Unknown'),
                'specialty': (d['specialization'] as String?) ?? 'General',
                // Placeholder images; you can replace with a profile_url field later
                'image':
                    'https://images.unsplash.com/photo-1559839734-2b71f90a6119?q=80&w=150&h=150&fit=crop',
                'id': d['id'] as String,
              },
            )
            .toList();
      });
    } catch (e) {
      // Keep UI usable with empty list; optionally show a snackbar
    } finally {
      setState(() => _loadingDoctors = false);
    }
  }

  Future<void> _loadRole() async {
    setState(() => _loadingRole = true);
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;
      String? role;
      if (user != null) {
        final res = await client
            .from('users')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();
        role = res?['role'] as String?;
      }
      setState(() {
        _role = role?.toLowerCase();
        _services = _filteredServicesForRole(_role);
        _loadingRole = false;
      });
    } catch (e) {
      setState(() {
        _role = null;
        _services = _allServices;
        _loadingRole = false;
      });
    }
  }
}
