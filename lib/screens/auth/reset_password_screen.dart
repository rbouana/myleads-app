import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  late final AnimationController _animController;
  late final Animation<double> _headerSlide;
  late final Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerSlide = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await ref.read(authProvider.notifier).resetPassword(
          widget.email,
          widget.code,
          _passwordController.text,
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _error = error;
      });
      return;
    }

    setState(() => _isLoading = false);

    // Show success toast then navigate to login.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.passwordResetSuccess),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );

    // Small delay so the user sees the snackbar before navigation.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Transform.translate(
                  offset: Offset(0, _headerSlide.value),
                  child: _buildHeader(),
                ),
                Opacity(
                  opacity: _formFade.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _formFade.value)),
                    child: _buildForm(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.newPasswordTitle,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.newPasswordSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white.withOpacity(0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error container
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // New password field
            _buildInputLabel(AppStrings.newPassword),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              maxLength: 15,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: '8-15 caractères',
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textLight.withOpacity(0.7),
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                if (value.length < 8 || value.length > 15) {
                  return 'Le mot de passe doit contenir entre 8 et 15 caractères';
                }
                if (value.contains(RegExp(r'\s'))) {
                  return 'Le mot de passe ne doit pas contenir d\'espaces';
                }
                if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                  return 'Le mot de passe doit contenir au moins une lettre';
                }
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'Le mot de passe doit contenir au moins un chiffre';
                }
                if (!value.contains(
                    RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/~`;]'))) {
                  return 'Le mot de passe doit contenir au moins un symbole';
                }
                return null;
              },
            ),

            const SizedBox(height: 6),

            // Password rules hint
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Text(
                AppStrings.passwordRules,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Confirm password field
            _buildInputLabel(AppStrings.confirmNewPassword),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              maxLength: 15,
              onFieldSubmitted: (_) => _handleReset(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Répétez le mot de passe',
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textLight.withOpacity(0.7),
                  size: 20,
                ),
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  child: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez confirmer votre mot de passe';
                }
                if (value != _passwordController.text) {
                  return AppStrings.passwordsMustMatch;
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Reset button
            _buildAccentButton(
              label: AppStrings.resetPassword,
              isLoading: _isLoading,
              onPressed: _handleReset,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAccentButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}
