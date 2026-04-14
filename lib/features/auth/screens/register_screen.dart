import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final outgoingEmail = _emailController.text.trim();
    final outgoingName = _nameController.text.trim();
    log('[RegisterScreen] Submitting: email=$outgoingEmail, name=$outgoingName');

    try {
      final user = await ref.read(authRepositoryProvider).signUp(
            email: outgoingEmail,
            password: _passwordController.text,
            name: outgoingName,
            college: _collegeController.text.trim(),
            department: _departmentController.text.trim(),
          );

      log('[RegisterScreen] ✅ Registration successful: ${user.email} (${user.role})');

      // Clear all fields
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _collegeController.clear();
      _departmentController.clear();

      // Refresh auth state — GoRouter redirect handles navigation
      ref.invalidate(currentUserProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully! 🎉'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }

    } on ApiError catch (e) {
      log('[RegisterScreen] ApiError: ${e.statusCode} — ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade700),
        );
      }
    } catch (e) {
      log('[RegisterScreen] Unexpected: $e');
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $msg'), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.person_add_rounded, size: 44, color: AppColors.primary),
                      ),
                      const SizedBox(height: 20),
                      Text('Create Account', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Join IT CLUB today', style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 32),

                      TextFormField(controller: _nameController, textCapitalization: TextCapitalization.words, validator: (v) => Validators.required(v, AppStrings.fullName), decoration: const InputDecoration(labelText: AppStrings.fullName, prefixIcon: Icon(Icons.person_outline))),
                      const SizedBox(height: 14),
                      TextFormField(controller: _collegeController, textCapitalization: TextCapitalization.words, validator: (v) => Validators.required(v, AppStrings.college), decoration: const InputDecoration(labelText: AppStrings.college, prefixIcon: Icon(Icons.school_outlined))),
                      const SizedBox(height: 14),
                      TextFormField(controller: _departmentController, textCapitalization: TextCapitalization.words, validator: (v) => Validators.required(v, AppStrings.department), decoration: const InputDecoration(labelText: AppStrings.department, prefixIcon: Icon(Icons.business_outlined))),
                      const SizedBox(height: 14),
                      TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, validator: Validators.email, decoration: const InputDecoration(labelText: AppStrings.email, prefixIcon: Icon(Icons.email_outlined))),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController, obscureText: _obscurePassword, validator: Validators.password,
                        decoration: InputDecoration(labelText: AppStrings.password, prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordController, obscureText: _obscureConfirm, validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                        decoration: InputDecoration(labelText: AppStrings.confirmPassword, prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      CustomButton(label: AppStrings.register, isLoading: _isLoading, useGradient: true, onPressed: _register),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(AppStrings.alreadyHaveAccount, style: Theme.of(context).textTheme.bodyMedium),
                        GestureDetector(onTap: () => context.go('/login'), child: Text(AppStrings.login, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary))),
                      ]),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
