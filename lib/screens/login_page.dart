import 'package:flutter/material.dart';
import '../Service/SupabaseService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- Supabase State & Logic ---
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _isPasswordVisible = false;
  String? _selectedRole; // 'patient' | 'doctor' | 'staff' | 'admin'

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role to continue')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await SupabaseService.instance.signIn(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      if (res.session != null) {
        // === SUCCESSFUL LOGIN: NAVIGATE TO DASHBOARD (/home) ===
        if (!mounted) return;
        // Route based on selected role. We'll start with patient first.
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
        // =======================================================
      } else {
        final msg = 'Login failed';
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // --- UI Helper Methods (Retained for visual consistency) ---

  Widget _buildInputField({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required bool isPassword,
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
        keyboardType: isPassword
            ? TextInputType.text
            : TextInputType.emailAddress,
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
        // TODO: Implement social sign-in logic
        print('$type login clicked');
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
                // Space from the top safe area
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                // 1. Logo
                Image.asset('images/MediChain.jpg', height: 50),
                const SizedBox(height: 50),

                // 2. Title
                const Text(
                  'Log In',
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
                    'Login as',
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

                // 3. Email Input Field
                _buildInputField(
                  icon: Icons.email_outlined,
                  hintText: 'Email address',
                  controller: _emailCtrl,
                  isPassword: false,
                  validator: (v) => v != null && v.contains('@')
                      ? null
                      : 'Enter a valid email',
                ),
                const SizedBox(height: 20),

                // 4. Password Input Field
                _buildInputField(
                  icon: Icons.lock_outline,
                  hintText: 'Password',
                  controller: _passwordCtrl,
                  isPassword: true,
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Password too short',
                ),
                const SizedBox(height: 10),

                // 5. Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password logic
                      print('Forgot Password clicked');
                    },
                    child: const Text(
                      'Forgot Password',
                      style: TextStyle(
                        color: Color(0xFF00ACC1),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 6. Sign In Button - Linked to _submit()
                _buildGradientButton(
                  text: 'Sign In',
                  onPressed: _submit,
                  isLoading: _loading,
                ),
                const SizedBox(height: 30),

                // 7. OR Separator
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

                // 8. Social Media Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton('google'),
                    const SizedBox(width: 30),
                    _buildSocialButton('facebook'),
                  ],
                ),
                const SizedBox(height: 60),

                // 9. Don't Have an Account? Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't Have an Account? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    InkWell(
                      onTap: () {
                        // Navigate to the '/register' route
                        Navigator.of(context).pushReplacementNamed('/register');
                      },
                      child: const Text(
                        'Sign Up',
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
