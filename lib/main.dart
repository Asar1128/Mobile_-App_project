import 'package:flutter/material.dart';
import 'Service/SupabaseService.dart';
// Core Screens
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/OnboardingScreen.dart'; 
// Model Management Screens
import 'screens/appointments_screen.dart';
import 'screens/doctors_list_screen.dart';
import 'screens/patients_list_screen.dart';
import 'screens/records_list_screen.dart';
import 'screens/prescriptions_screen.dart';
import 'screens/hospital_detail_screen.dart';
import 'screens/staff_list_screen.dart';
// NEW DETAIL SCREENS
import 'screens/doctor_detail_screen.dart';
import 'screens/appointment_booking_screen.dart';
// === FIX 1: Import the Doctor model class for type checking ===
import 'package:hospital_management_system/Model_Classes/doctor.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Only initialize Supabase. We do not perform navigation based on Auth state here yet.
    await SupabaseService.init();
  } catch (e) {
    print('Error initializing Supabase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediChain HMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4DD0E1)),
        useMaterial3: true,
      ),
      initialRoute: '/onboarding',
      routes: {
        // --- Core Authentication Flow ---
        '/onboarding': (context) => const OnboardingScreen(), 
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // --- Dashboard and Main Navigation ---
        '/home': (context) => const HomePage(),
        
        // --- Model-Specific Management Screens (Lists) ---
        '/appointments': (context) => const AppointmentsScreen(),
        '/doctors': (context) => const DoctorsListScreen(),
        '/patients': (context) => const PatientsListScreen(),
        '/records': (context) => const MedicalRecordsScreen(),
        '/prescriptions': (context) => const PrescriptionsScreen(),
        '/hospital_admin': (context) => const HospitalDetailScreen(),
        '/staff': (context) => const StaffListScreen(), 
      },
      
      // OnGenerateRoute for screens needing dynamic arguments (like DoctorDetailScreen)
      onGenerateRoute: (settings) {
        if (settings.name == '/doctor_detail') {
          // Type cast now works because Doctor is imported
          final doctor = settings.arguments as Doctor;
          return MaterialPageRoute(builder: (context) => DoctorDetailScreen(doctor: doctor));
        }
        return null;
      },
    );
  }
}