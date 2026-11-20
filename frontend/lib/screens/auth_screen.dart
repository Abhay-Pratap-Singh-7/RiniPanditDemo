import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cosmic_scaffold.dart';
import 'home_screen.dart';
import 'pandit/pandit_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  final String initialRole;

  const AuthScreen({super.key, this.initialRole = 'user'});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  late String _role;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rateController = TextEditingController(text: '25');

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final appState = context.read<AppState>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    if (_isSignUp && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    bool success;
    if (_isSignUp) {
      final rate = double.tryParse(_rateController.text.trim()) ?? 25.0;
      success = await appState.signUpWithSupabase(
        email: email,
        password: password,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _role,
        ratePerMinute: _role == 'pandit' ? rate : null,
        specialties: _role == 'pandit' ? const ['Vedic', 'Kundli'] : null,
        experienceYears: _role == 'pandit' ? 5 : null,
        bio: _role == 'pandit' ? '' : null,
      );
    } else {
      success = await appState.signInWithSupabase(
        email: email,
        password: password,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSignUp ? 'Account created successfully with Supabase.' : 'Signed in successfully.',
          ),
          backgroundColor: AppTheme.cardPurple,
        ),
      );

      if (appState.isPandit) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PanditDashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.errorMessage ?? 'Authentication failed.',
            style: const TextStyle(color: Colors.white, fontSize: 13),
            softWrap: true,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return CosmicScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Emblem
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppTheme.cardPurple.withAlpha(45),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.cardLilac, width: 1.5),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppTheme.cardLilac, size: 38),
                  ),
                ),
                const SizedBox(height: 18),

                // Title
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: const [
                      Text(
                        'Rini Pandit Astrology',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        _isSignUp ? 'Create your account with Supabase' : 'Sign in to access your consultations & wallet',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Role Selector Tabs (Client vs Pandit) - Only on Sign Up
                if (_isSignUp) ...[
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderSubtle, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _role = 'user'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _role == 'user' ? AppTheme.cardPurple : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Client / Devotee',
                                  style: TextStyle(
                                    color: _role == 'user' ? Colors.white : AppTheme.textMuted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _role = 'pandit'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _role == 'pandit' ? AppTheme.cardPurple : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Acharya / Pandit',
                                  style: TextStyle(
                                    color: _role == 'pandit' ? Colors.white : AppTheme.textMuted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Form Container Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: AppTheme.cardRadius,
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isSignUp) ...[
                        // Full Name
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: _role == 'pandit' ? 'Acharya Full Name' : 'Full Name',
                            hintText: 'e.g. Rahul Sharma',
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.cardLilac, size: 20),
                            filled: true,
                            fillColor: AppTheme.surfaceTile,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.borderSubtle),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Phone Number
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '+919876543210',
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.cardLilac, size: 20),
                            filled: true,
                            fillColor: AppTheme.surfaceTile,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: AppTheme.borderSubtle),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (_role == 'pandit') ...[
                          // Rate Per Minute
                          TextField(
                            controller: _rateController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Consultation Rate (₹ / min)',
                              prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppTheme.cardLilac, size: 20),
                              filled: true,
                              fillColor: AppTheme.surfaceTile,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.borderSubtle),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],

                      // Email Address
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'name@example.com',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.cardLilac, size: 20),
                          filled: true,
                          fillColor: AppTheme.surfaceTile,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.borderSubtle),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.cardLilac, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceTile,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppTheme.borderSubtle),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Primary Action Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cardPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: appState.isLoading ? null : _handleSubmit,
                          child: appState.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _isSignUp ? 'Create Account' : 'Sign In',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Toggle Sign In vs Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? 'Already have an account?' : 'Do not have an account?',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(
                        _isSignUp ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(color: AppTheme.cardLilac, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
