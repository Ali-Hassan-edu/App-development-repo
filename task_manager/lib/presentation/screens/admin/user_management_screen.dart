import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../domain/entities/user_entity.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';
  static const primaryColor = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: const Text(
          'Team Members',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(allUsersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            child: Column(
              children: [
                usersAsync.when(
                  data: (users) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        _StatPill('Total', users.length.toString(),
                            Icons.people_alt_rounded),
                        const SizedBox(width: 10),
                        _StatPill(
                          'Admins',
                          users
                              .where((u) => u.role == UserRole.admin)
                              .length
                              .toString(),
                          Icons.admin_panel_settings_rounded,
                        ),
                        const SizedBox(width: 10),
                        _StatPill(
                          'Users',
                          users
                              .where((u) => u.role == UserRole.user)
                              .length
                              .toString(),
                          Icons.person_rounded,
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(height: 20),
                  error: (_, __) => const SizedBox(height: 20),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search members...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon:
                          const Icon(Icons.search, color: primaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(allUsersProvider.future),
                child: usersAsync.when(
                  data: (users) {
                    final filtered = _searchQuery.isEmpty
                        ? users
                        : users
                            .where((u) =>
                                u.name
                                    .toLowerCase()
                                    .contains(_searchQuery) ||
                                u.email
                                    .toLowerCase()
                                    .contains(_searchQuery))
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No team members yet'
                                  : 'No results for "$_searchQuery"',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Tap + to add your first user',
                                  style: TextStyle(
                                      color: Colors.grey.shade500)),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _buildUserCard(filtered[index]),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Failed to load: $error',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () =>
                              ref.refresh(allUsersProvider.future),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add User',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ─── User Card ──────────────────────────────────────────────────────────────

  Widget _buildUserCard(UserEntity user) {
    final isAdmin = user.role == UserRole.admin;
    final roleColor = isAdmin ? const Color(0xFFE65100) : primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAdmin
                      ? [const Color(0xFFE65100), const Color(0xFFFF6D00)]
                      : [primaryColor, const Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: roleColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAdmin ? 'ADMIN' : 'USER',
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, color: Colors.red, size: 20),
                      SizedBox(width: 10),
                      Text('Remove',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'remove') _confirmRemoveUser(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Confirm Remove User Dialog ─────────────────────────────────────────────

  void _confirmRemoveUser(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Remove User',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E))),
          ],
        ),
        content: Text(
            'Remove ${user.name} from the team? Their tasks will remain but unassigned.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(userStateProvider.notifier).removeUser(user.id);
              ref.invalidate(allUsersProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${user.name} has been removed'),
                  backgroundColor: Colors.orange,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  } // ← _confirmRemoveUser closing brace

  // ─── Add User Dialog ────────────────────────────────────────────────────────

  void _showAddUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    UserRole selectedRole = UserRole.user;
    bool isLoading = false;
    bool submitted = false;
    bool obscurePassword = true;

    // dialogMounted: set to false BEFORE Navigator.pop so setDialogState
    // is never called on a disposed StatefulBuilder.
    bool dialogMounted = true;

    void safeSetDialog(StateSetter setDS, VoidCallback fn) {
      if (dialogMounted) setDS(fn);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return WillPopScope(
            onWillPop: () async => !isLoading,
            child: Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 18),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Header ──────────────────────────────────────
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  color: Colors.white,
                                  size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Add Team Member',
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1A1A2E))),
                                  SizedBox(height: 4),
                                  Text(
                                    'Create a new user and send credentials automatically.',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF666666),
                                        height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Form Fields ──────────────────────────────────
                        _buildClearField(
                          controller: nameController,
                          label: 'Full Name',
                          hint: 'Enter full name',
                          icon: Icons.person_outline_rounded,
                          enabled: !isLoading,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter full name';
                            }
                            if (v.trim().length < 3) return 'Name is too short';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildClearField(
                          controller: emailController,
                          label: 'Email Address',
                          hint: 'Enter email address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                          validator: (v) {
                            final e = v?.trim() ?? '';
                            if (e.isEmpty) return 'Please enter email address';
                            if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$')
                                .hasMatch(e)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildClearField(
                          controller: passwordController,
                          label: 'Password',
                          hint: 'Minimum 6 characters',
                          icon: Icons.lock_outline_rounded,
                          obscureText: obscurePassword,
                          enabled: !isLoading,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter password';
                            }
                            if (v.trim().length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            onPressed: isLoading
                                ? null
                                : () => safeSetDialog(setDialogState, () {
                                      obscurePassword = !obscurePassword;
                                    }),
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── Role Dropdown ────────────────────────────────
                        DropdownButtonFormField<UserRole>(
                          initialValue: selectedRole,
                          style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            labelStyle: const TextStyle(
                                color: Color(0xFF444444),
                                fontWeight: FontWeight.w600),
                            prefixIcon: const Icon(Icons.badge_outlined,
                                color: primaryColor),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFFD6D6D6)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: Color(0xFFD6D6D6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 1.8),
                            ),
                          ),
                          items: UserRole.values.map((role) {
                            final isAdminRole = role == UserRole.admin;
                            return DropdownMenuItem<UserRole>(
                              value: role,
                              child: Row(children: [
                                Icon(
                                  isAdminRole
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.person_rounded,
                                  size: 18,
                                  color: isAdminRole
                                      ? const Color(0xFFE65100)
                                      : primaryColor,
                                ),
                                const SizedBox(width: 10),
                                Text(isAdminRole ? 'Admin' : 'User'),
                              ]),
                            );
                          }).toList(),
                          onChanged: isLoading
                              ? null
                              : (role) {
                                  if (role != null) {
                                    safeSetDialog(setDialogState,
                                        () => selectedRole = role);
                                  }
                                },
                        ),
                        const SizedBox(height: 16),

                        // ── Info box ─────────────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F7FF),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: const Color(0xFFD5E6FF)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: primaryColor, size: 18),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'The account will be created under your admin workspace and the login credentials will be emailed automatically.',
                                  style: TextStyle(
                                      color: Color(0xFF245B96),
                                      fontSize: 12.8,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ── Buttons ──────────────────────────────────────
                        Row(
                          children: [
                            // Cancel — flex:1, same as Create User flex:1
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        dialogMounted = false;
                                        Navigator.pop(dialogCtx);
                                      },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 52),
                                  side: const BorderSide(
                                      color: Color(0xFFD6D6D6)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Create User — flex:1, same width as Cancel
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        if (submitted) return;
                                        FocusScope.of(dialogCtx).unfocus();
                                        if (!formKey.currentState!
                                            .validate()) {
                                          return;
                                        }

                                        submitted = true;
                                        final name =
                                            nameController.text.trim();
                                        final email =
                                            emailController.text.trim();
                                        final password =
                                            passwordController.text.trim();

                                        safeSetDialog(setDialogState,
                                            () => isLoading = true);

                                        try {
                                          final newUser = await ref
                                              .read(authStateProvider
                                                  .notifier)
                                              .createUserWithoutSession(
                                                name,
                                                email,
                                                password,
                                                selectedRole,
                                              );

                                          if (newUser != null) {
                                            // Send welcome email while dialog open
                                            try {
                                              await ref
                                                  .read(emailServiceProvider)
                                                  .sendNewUserCredentials(
                                                    userEmail: newUser.email,
                                                    userName: newUser.name,
                                                    password: password,
                                                    role: selectedRole ==
                                                            UserRole.admin
                                                        ? 'Admin'
                                                        : 'User',
                                                  );
                                            } catch (emailErr) {
                                              debugPrint(
                                                  'Email (non-fatal): $emailErr');
                                            }

                                            try {
                                              await PushNotificationService()
                                                  .showWelcome(
                                                      userName: newUser.name);
                                            } catch (_) {}

                                            // Set dialogMounted=false BEFORE pop
                                            // to prevent setState-after-dispose crash
                                            dialogMounted = false;
                                            if (dialogCtx.mounted) {
                                              Navigator.pop(dialogCtx);
                                            }

                                            // createUserWithoutSession now awaits
                                            // full session restore. Give Supabase
                                            // 1.5s to settle before refreshing.
                                            await Future.delayed(
                                                const Duration(
                                                    milliseconds: 1500));
                                            if (mounted) {
                                              ref.invalidate(allUsersProvider);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                  '✅ ${newUser.name} created! Credentials emailed to ${newUser.email}',
                                                ),
                                                backgroundColor: Colors.green,
                                                duration: const Duration(
                                                    seconds: 4),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ));
                                            }
                                          } else {
                                            submitted = false;
                                            safeSetDialog(setDialogState,
                                                () => isLoading = false);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Failed to create user. Email may already exist.'),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ));
                                            }
                                          }
                                        } catch (e) {
                                          submitted = false;
                                          safeSetDialog(setDialogState,
                                              () => isLoading = false);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ));
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 52),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16)),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: Colors.white))
                                    : const Text('Create User',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  } // ← _showAddUserDialog closing brace

  // ─── Text Field Builder ──────────────────────────────────────────────────────

  Widget _buildClearField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    bool enabled = true,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 16,
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
            color: Color(0xFF444444), fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(
            color: Color(0xFF9A9A9A), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
        ),
      ),
    );
  }
} // ← _UserManagementScreenState closing brace

// ─── Stat Pill Widget ────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;

  const _StatPill(this.label, this.count, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(count,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16)),
            const SizedBox(width: 4),
            Text(label,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
