import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/user_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/profile/bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _editQuoteDialog(UserEntity user) {
    _quoteController.text = user.quote;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Text("Edit Your Quote "),
              Text("✨", style: TextStyle(fontSize: 20)),
            ],
          ),
          content: TextField(
            controller: _quoteController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: "Enter your personal motivational quote...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: PockiColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PockiColors.primaryPink,
                minimumSize: const Size(100, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                final newQuote = _quoteController.text.trim();
                if (newQuote.isNotEmpty) {
                  final updatedUser = user.copyWith(quote: newQuote, updatedAt: DateTime.now());
                  context.read<ProfileBloc>().add(
                        UpdateProfileQuoteEvent(currentUser: user, newQuote: newQuote),
                      );
                  context.read<AuthBloc>().add(UpdateAuthUserEvent(updatedUser));
                }
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Quote updated! ✨")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _editProfileDialog(UserEntity user) {
    _nameController.text = user.name;
    _nicknameController.text = user.nickname;
    _phoneController.text = user.phone;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            top: 24,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Edit Profile 👤✨",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text("Full Name", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PockiColors.textMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Enter full name",
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 14),

                const Text("Nickname / Username", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PockiColors.textMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: "Enter nickname",
                    prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 14),

                const Text("Phone Number", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PockiColors.textMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "Enter phone number",
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    final name = _nameController.text.trim();
                    final nickname = _nicknameController.text.trim();
                    final phone = _phoneController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Name cannot be empty 😅"),
                          backgroundColor: PockiColors.errorRed,
                        ),
                      );
                      return;
                    }

                    final updatedUser = user.copyWith(
                      name: name,
                      nickname: nickname.isEmpty ? 'user' : nickname,
                      phone: phone,
                      updatedAt: DateTime.now(),
                    );

                    context.read<ProfileBloc>().add(
                          UpdateProfileInfoEvent(
                            currentUser: user,
                            name: name,
                            nickname: nickname.isEmpty ? 'user' : nickname,
                            phone: phone,
                          ),
                        );
                    context.read<AuthBloc>().add(UpdateAuthUserEvent(updatedUser));
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated! 💖✨")),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: PockiColors.primaryGradient,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const Center(
                      child: Text(
                        "Save Profile",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PockiColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthenticatedState) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = authState.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("👑 ✨ ⭐ 👛 🌸", style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _editProfileDialog(user),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.edit_outlined, color: PockiColors.primaryPink, size: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/settings'),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.settings_outlined, color: PockiColors.textDark, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Avatar & Edit Action
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: PockiColors.purpleGradient,
                              ),
                            ),
                            Container(
                              width: 102,
                              height: 102,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: PockiColors.pinkTint,
                              ),
                              child: const Center(
                                child: Text("👩🏻‍💼", style: TextStyle(fontSize: 54)),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 4,
                              child: GestureDetector(
                                onTap: () => _editProfileDialog(user),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit_rounded, size: 14, color: PockiColors.primaryPink),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _editProfileDialog(user),
                              child: const Icon(Icons.edit_outlined, size: 16, color: PockiColors.primaryPink),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: PockiColors.primaryPink.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "@${user.nickname}",
                            style: const TextStyle(
                              color: PockiColors.primaryPink,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quote Card
                  GestureDetector(
                    onTap: () => _editQuoteDialog(user),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              const Text(
                                "“",
                                style: TextStyle(fontSize: 32, height: 0.8, color: PockiColors.mintGreen, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.quote,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: PockiColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  "”",
                                  style: TextStyle(fontSize: 32, height: 0.8, color: PockiColors.primaryPink, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Positioned(
                            right: 0,
                            top: 0,
                            child: Icon(Icons.edit_outlined, size: 16, color: PockiColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInfoCard(Icons.email_outlined, user.email),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.phone_outlined,
                    user.phone.isEmpty ? "Add phone number" : user.phone,
                    onTap: () => _editProfileDialog(user),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.calendar_month_outlined,
                    "Member since ${DateFormat('MMMM yyyy').format(user.createdAt)}",
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: PockiColors.textMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: PockiColors.textDark,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, size: 20, color: PockiColors.textMuted),
          ],
        ),
      ),
    );
  }
}
