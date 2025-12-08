import 'package:flutter/material.dart';
import '../Service/SupabaseService.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _isPasswordVisible = false;
  bool _termsAccepted = false;
  String _selectedRole = 'patient'; // default role
  String? _selectedHospitalId; // optional, can be set later via staff/admin
  List<Map<String, dynamic>> _hospitals = [];
  bool _loadingHospitals = false;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    setState(() => _loadingHospitals = true);
    try {
      final client = SupabaseService.instance.client;
      final res = await client
          .from('hospitals')
          .select('id,name')
          .order('name');
      setState(() {
        _hospitals = (res as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      // Silent fail; user can proceed without hospital for now
    } finally {
      setState(() => _loadingHospitals = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the Terms & Conditions to register.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await SupabaseService.instance.signUp(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      debugPrint('[Register] signUp response: ' + res.toString());
      final client = SupabaseService.instance.client;
      if (res.user != null) {
        final userId = res.user!.id;
        // Create profile row in users table
        await client.from('users').insert({
          'id': userId,
          'email': _emailCtrl.text.trim(),
          'full_name': _fullNameCtrl.text.trim(),
          'role': _selectedRole,
          'hospital_id': _selectedHospitalId,
        });
        debugPrint('[Register] inserted users row for ' + userId);
        // Create role row (patients/doctors/staff) to link auth user
        if (_selectedRole == 'patient') {
          await client.from('patients').insert({
            'user_id': userId,
            'hospital_id': _selectedHospitalId,
          });
          debugPrint('[Register] inserted patients row for ' + userId);
        } else if (_selectedRole == 'doctor') {
          await client.from('doctors').insert({
            'user_id': userId,
            'hospital_id': _selectedHospitalId,
          });
          debugPrint('[Register] inserted doctors row for ' + userId);
        } else if (_selectedRole == 'staff') {
          await client.from('staff').insert({
            'user_id': userId,
            'hospital_id': _selectedHospitalId,
          });
          debugPrint('[Register] inserted staff row for ' + userId);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        // Navigate directly to role-specific home/dashboard
        switch (_selectedRole) {
          case 'patient':
            Navigator.of(context).pushReplacementNamed('/home');
            break;
          case 'doctor':
            Navigator.of(context).pushReplacementNamed('/doctors');
            break;
          case 'staff':
            Navigator.of(context).pushReplacementNamed('/staff');
            break;
          case 'admin':
            Navigator.of(context).pushReplacementNamed('/admin');
            break;
          default:
            Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        final msg = 'Registration failed';
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e, st) {
      // Log detailed error in terminal/console
      debugPrint('[Register] ERROR: ' + e.toString());
      debugPrint('[Register] STACK: ' + st.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // --- UI Helper Methods (Shared from Login) ---

  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required bool isPassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          prefixIcon: Icon(icon, color: const Color(0xFF4DD0E1)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          fillColor: Colors.transparent,
          filled: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: isLoading
            ? LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              )
            : const LinearGradient(
                colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
      ),
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSocialButton(String type) {
    String url = type == 'google'
        ? 'https://img.icons8.com/color/48/000000/google-logo.png'
        : 'https://img.icons8.com/color/48/000000/facebook-new.png';

    return InkWell(
      onTap: () {
        // TODO: Implement social sign-up logic
        print('$type sign up clicked');
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Image.network(
            url,
            height: 30,
            width: 30,
            errorBuilder: (context, error, stackTrace) => Text(
              type == 'google' ? 'G' : 'F',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 30.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                // 1. Logo (Corrected Path)
                Image.asset(
                  'images/MediChain.jpg', // Using the exact path you specified
                  height: 50,
                  // Removed the manual errorBuilder text placeholder
                ),
                const SizedBox(height: 50),

                // 2. Title
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                // Role selection
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Register as',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _roleChip('patient'),
                    _roleChip('doctor'),
                    _roleChip('staff'),
                    _roleChip('admin'),
                  ],
                ),
                const SizedBox(height: 20),

                // Hospital selection (optional)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hospital (optional)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _loadingHospitals
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: _selectedHospitalId,
                        items: _hospitals
                            .map(
                              (h) => DropdownMenuItem<String>(
                                value: h['id'] as String,
                                child: Text(h['name'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedHospitalId = val),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // 3. Full Name Input Field
                _buildInputField(
                  icon: Icons.person_outline,
                  hintText: 'Full Name',
                  controller: _fullNameCtrl,
                  isPassword: false,
                  validator: (v) =>
                      v != null && v.isNotEmpty ? null : 'Enter your full name',
                ),
                const SizedBox(height: 20),

                // 4. Mobile Number Input Field
                _buildInputField(
                  icon: Icons.phone_outlined,
                  hintText: 'Mobile Number',
                  controller: _mobileCtrl,
                  isPassword: false,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v != null && v.length >= 10
                      ? null
                      : 'Enter a valid mobile number',
                ),
                const SizedBox(height: 20),

                // 5. Email Input Field
                _buildInputField(
                  icon: Icons.email_outlined,
                  hintText: 'Email address',
                  controller: _emailCtrl,
                  isPassword: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v != null && v.contains('@')
                      ? null
                      : 'Enter a valid email',
                ),
                const SizedBox(height: 20),

                // 6. Password Input Field
                _buildInputField(
                  icon: Icons.lock_outline,
                  hintText: 'Password',
                  controller: _passwordCtrl,
                  isPassword: true,
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Password too short',
                ),
                const SizedBox(height: 20),

                // 7. Terms & Conditions Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _termsAccepted = newValue ?? false;
                        });
                      },
                      activeColor: const Color(0xFF00ACC1),
                    ),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I accept all the ',
                          style: TextStyle(fontSize: 13, color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00ACC1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 8. Sign Up Button - Linked to _submit()
                _buildGradientButton(
                  text: 'Sign Up',
                  onPressed: _submit,
                  isLoading: _loading,
                ),
                const SizedBox(height: 30),

                // 9. OR Separator
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 30),

                // 10. Social Media Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton('google'),
                    const SizedBox(width: 30),
                    _buildSocialButton('facebook'),
                  ],
                ),
                const SizedBox(height: 60),

                // 11. Have an Account? Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Have an Account? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    InkWell(
                      onTap: () {
                        // Navigate to the '/login' route
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF00ACC1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(String role) {
    final selected = _selectedRole == role;
    return ChoiceChip(
      label: Text(role[0].toUpperCase() + role.substring(1)),
      selected: selected,
      onSelected: (val) {
        setState(() => _selectedRole = role);
      },
      selectedColor: const Color(0xFF00ACC1),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
