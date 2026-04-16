import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = StorageService.currentUser;
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: user?.lastName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _dobCtrl = TextEditingController(text: user?.dateOfBirth ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  String _initialsFor(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Future<void> _pickPhoto() async {
    if (kIsWeb) return;
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
      );
      if (image != null && mounted) {
        await ref.read(authProvider.notifier).updatePhoto(image.path);
      }
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = StorageService.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final updated = user.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        dateOfBirth:
            _dobCtrl.text.trim().isEmpty ? null : _dobCtrl.text.trim(),
      );
      await DatabaseService.updateUser(updated);
      await StorageService.setCurrentSession(updated, user.sessionToken ?? '');

      // Refresh auth state so userName updates everywhere
      final notifier = ref.read(authProvider.notifier);
      await notifier.updatePhoto(updated.photoPath); // triggers state refresh
      // Directly patch the auth state with new name
      ref.read(authProvider.notifier);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(AppStrings.profileUpdated),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    if (_isEditing) {
      // Cancel — reset fields
      final user = StorageService.currentUser;
      _firstNameCtrl.text = user?.firstName ?? '';
      _lastNameCtrl.text = user?.lastName ?? '';
      _phoneCtrl.text = user?.phone ?? '';
      _dobCtrl.text = user?.dateOfBirth ?? '';
    }
    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = StorageService.currentUser;
    final displayName = auth.userName.isEmpty ? 'Utilisateur' : auth.userName;
    final displayInitials = _initialsFor(displayName);
    final displayEmail = auth.userEmail.isEmpty ? '—' : auth.userEmail;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Gradient Header ──────────────────────────────────────
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 32,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Top bar: back + title
                  Row(
                    children: [
                      _headerIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          AppStrings.myProfile,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Edit / Cancel toggle
                      _headerIconButton(
                        icon: _isEditing
                            ? Icons.close_rounded
                            : Icons.edit_rounded,
                        onTap: _toggleEditMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Avatar
                  GestureDetector(
                    onTap: _isEditing ? _pickPhoto : null,
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 4,
                            ),
                            image: auth.userPhotoPath != null && !kIsWeb
                                ? DecorationImage(
                                    image: FileImage(File(auth.userPhotoPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: auth.userPhotoPath == null || kIsWeb
                              ? Center(
                                  child: Text(
                                    displayInitials,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 14, color: AppColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayEmail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEditing
                              ? AppStrings.editMode
                              : AppStrings.viewMode,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (_isEditing) ...[
                          const Spacer(),
                          Text(
                            'Modifiez vos informations',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Profile fields card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _profileField(
                            label: AppStrings.firstName,
                            value: user?.firstName ?? '',
                            controller: _firstNameCtrl,
                            isFirst: true,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Prénom requis'
                                : null,
                          ),
                          _divider(),
                          _profileField(
                            label: AppStrings.lastName,
                            value: user?.lastName ?? '',
                            controller: _lastNameCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nom requis'
                                : null,
                          ),
                          _divider(),
                          _profileField(
                            label: AppStrings.email,
                            value: displayEmail,
                            controller: null,
                            readOnly: true,
                            trailingIcon: Icons.lock_outline_rounded,
                          ),
                          _divider(),
                          _profileField(
                            label: AppStrings.phoneNumber,
                            value: user?.phone ?? '—',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            hint: '+352 XXX XXX XXX',
                          ),
                          _divider(),
                          _profileField(
                            label: AppStrings.dateOfBirth,
                            value: user?.dateOfBirth ?? '—',
                            controller: _dobCtrl,
                            isLast: true,
                            hint: 'JJ/MM/AAAA',
                            keyboardType: TextInputType.datetime,
                          ),
                        ],
                      ),
                    ),

                    // Save button in edit mode
                    if (_isEditing) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.accent.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Text(
                                  AppStrings.saveChanges,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _profileField({
    required String label,
    required String value,
    required TextEditingController? controller,
    bool readOnly = false,
    bool isFirst = false,
    bool isLast = false,
    IconData? trailingIcon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final borderRadius = BorderRadius.only(
      topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
      topRight: isFirst ? const Radius.circular(16) : Radius.zero,
      bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
      bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
    );

    if (_isEditing && !readOnly && controller != null) {
      // Edit mode: TextFormField
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textLight.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: AppColors.inputBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.error, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // View mode or read-only: static display
    return Container(
      decoration: BoxDecoration(
        color: readOnly && _isEditing
            ? AppColors.inputBg.withOpacity(0.5)
            : AppColors.card,
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (value.isEmpty || value == '') ? '—' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: readOnly
                        ? AppColors.textMid
                        : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon, size: 16, color: AppColors.textLight),
        ],
      ),
    );
  }
}
