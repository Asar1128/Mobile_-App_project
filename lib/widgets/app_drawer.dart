import 'package:flutter/material.dart';
import '../Service/SupabaseService.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Define the main list of navigational destinations
  static const List<Map<String, dynamic>> menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/home'},
    {
      'title': 'Appointments',
      'icon': Icons.calendar_today,
      'route': '/appointments',
    },
    {
      'title': 'Doctor Directory',
      'icon': Icons.medical_services,
      'route': '/doctors',
    },
    {'title': 'Patient List', 'icon': Icons.people, 'route': '/patients'},
    {
      'title': 'Medical Records',
      'icon': Icons.folder_open,
      'route': '/records',
    },
    {
      'title': 'Prescriptions',
      'icon': Icons.receipt_long,
      'route': '/prescriptions',
    },
    {
      'title': 'Hospital Management',
      'icon': Icons.apartment,
      'route': '/hospital_admin',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final client = SupabaseService.instance.client;
    final authUser = client.auth.currentUser;
    return Drawer(
      child: Container(
        // Background color consistency
        color: const Color(0xFFF7FCFF),
        child: Column(
          children: <Widget>[
            // Drawer Header (Blue Gradient)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 20, left: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: authUser == null
                    ? Future<Map<String, dynamic>?>.value(null)
                    : client
                          .from('users')
                          .select('full_name, role, email')
                          .eq('id', authUser.id)
                          .maybeSingle()
                          .then<Map<String, dynamic>?>((value) => value),
                builder: (context, snap) {
                  final isLoading =
                      snap.connectionState != ConnectionState.done;
                  final profile = snap.data;
                  final displayName =
                      profile?['full_name'] as String? ??
                      (authUser?.email ?? 'User');
                  final displayEmail =
                      profile?['email'] as String? ?? (authUser?.email ?? '');
                  final displayRole = (profile?['role'] as String?)
                      ?.toUpperCase();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person_outline,
                          color: Color(0xFF00ACC1),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isLoading ? 'Loading...' : displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isLoading && displayRole != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            displayRole,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      Text(
                        isLoading ? '' : displayEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Menu Items
            Expanded(
              child: FutureBuilder<Map<String, dynamic>?>(
                future: authUser == null
                    ? Future<Map<String, dynamic>?>.value(null)
                    : client
                          .from('users')
                          .select('role')
                          .eq('id', authUser.id)
                          .maybeSingle()
                          .then<Map<String, dynamic>?>((value) => value),
                builder: (context, snap) {
                  final role = (snap.data?['role'] as String?)?.toLowerCase();
                  final filtered = _filteredMenuForRole(role);
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: filtered
                        .map(
                          (item) => _buildDrawerItem(
                            context,
                            item['title'],
                            item['icon'],
                            item['route'],
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),

            // Footer/Logout Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  onPressed: () async {
                    try {
                      await client.auth.signOut();
                    } finally {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filteredMenuForRole(String? role) {
    if (role == null) return menuItems;
    switch (role) {
      case 'doctor':
        return [
          {
            'title': 'Dashboard',
            'icon': Icons.dashboard,
            'route': '/doctor_home',
          },
          {
            'title': 'Appointments',
            'icon': Icons.calendar_today,
            'route': '/appointments',
          },
          {'title': 'Patient List', 'icon': Icons.people, 'route': '/patients'},
          {
            'title': 'Medical Records',
            'icon': Icons.folder_open,
            'route': '/records',
          },
          {
            'title': 'Prescriptions',
            'icon': Icons.receipt_long,
            'route': '/prescriptions',
          },
        ];
      case 'admin':
        return [
          {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/home'},
          {
            'title': 'Appointments',
            'icon': Icons.calendar_today,
            'route': '/appointments',
          },
          {
            'title': 'Doctor Directory',
            'icon': Icons.medical_services,
            'route': '/doctors',
          },
          {'title': 'Patient List', 'icon': Icons.people, 'route': '/patients'},
          {
            'title': 'Medical Records',
            'icon': Icons.folder_open,
            'route': '/records',
          },
          {
            'title': 'Prescriptions',
            'icon': Icons.receipt_long,
            'route': '/prescriptions',
          },
          {
            'title': 'Hospital Management',
            'icon': Icons.apartment,
            'route': '/hospital_admin',
          },
        ];
      case 'staff':
        return [
          {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/home'},
          {
            'title': 'Appointments',
            'icon': Icons.calendar_today,
            'route': '/appointments',
          },
          {
            'title': 'Doctor Directory',
            'icon': Icons.medical_services,
            'route': '/doctors',
          },
          {'title': 'Patient List', 'icon': Icons.people, 'route': '/patients'},
        ];
      case 'patient':
      default:
        return [
          {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/home'},
          {
            'title': 'Appointments',
            'icon': Icons.calendar_today,
            'route': '/appointments',
          },
          {
            'title': 'Doctor Directory',
            'icon': Icons.medical_services,
            'route': '/doctors',
          },
          {
            'title': 'Medical Records',
            'icon': Icons.folder_open,
            'route': '/records',
          },
          {
            'title': 'Prescriptions',
            'icon': Icons.receipt_long,
            'route': '/prescriptions',
          },
        ];
    }
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    // Determine if the current route matches the item's route for highlighting
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF4DD0E1).withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF00ACC1) : Colors.black54,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00ACC1) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close the drawer
          if (currentRoute != route) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
      ),
    );
  }
}
