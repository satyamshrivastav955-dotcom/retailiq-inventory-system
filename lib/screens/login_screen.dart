import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUp = false; // Toggle between Sign In and Sign Up
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    bool success;

    if (_isSignUp) {
      success = await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _formKey.currentState?.reset();
    });
    Provider.of<AuthProvider>(context, listen: false).clearError();
  }

  void _handleForgotPassword() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: AppDecorations.inputDecoration(
                'Email Address',
                icon: Icons.email_outlined,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              final validationError = validateEmail(email);
              if (validationError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(validationError),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.sendPasswordReset(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Password reset email sent to $email'
                          : authProvider.error ?? 'Failed to send reset email'),
                      backgroundColor:
                          success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF2C5F8A),
              Color(0xFF1E3A5F),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / App Name
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        size: 64,
                        color: AppColors.accentLight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      kAppName,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      kAppTagline,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Login/Signup Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isSignUp ? 'Create Account' : 'Welcome Back',
                              style: AppTextStyles.heading2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isSignUp
                                  ? 'Register to manage your store'
                                  : 'Sign in to manage your store',
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),

                            // Name (Sign Up only)
                            if (_isSignUp) ...[
                              TextFormField(
                                controller: _nameController,
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: AppDecorations.inputDecoration(
                                  'Full Name',
                                  icon: Icons.person_outlined,
                                ),
                                validator: (v) =>
                                    validateRequired(v, 'Name'),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: AppDecorations.inputDecoration(
                                'Email Address',
                                icon: Icons.email_outlined,
                              ),
                              validator: validateEmail,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: AppDecorations.inputDecoration(
                                'Password',
                                icon: Icons.lock_outlined,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: validatePassword,
                            ),
                            const SizedBox(height: 24),

                            // Error message
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                if (auth.error != null) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.error
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline,
                                              color: AppColors.error,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              auth.error!,
                                              style: const TextStyle(
                                                  color: AppColors.error,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Submit Button
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading
                                        ? null
                                        : _handleSubmit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      elevation: 3,
                                    ),
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _isSignUp
                                                ? 'Sign Up'
                                                : 'Sign In',
                                            style: AppTextStyles.button,
                                          ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            // Forgot Password (Sign In only)
                            if (!_isSignUp)
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _handleForgotPassword,
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.primaryLight,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Toggle Sign In / Sign Up
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isSignUp
                                      ? 'Already have an account? '
                                      : "Don't have an account? ",
                                  style: AppTextStyles.bodySecondary,
                                ),
                                GestureDetector(
                                  onTap: _toggleMode,
                                  child: Text(
                                    _isSignUp ? 'Sign In' : 'Sign Up',
                                    style: const TextStyle(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
