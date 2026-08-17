import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/profile/bloc/profile_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _budgetController = TextEditingController();

  void _showSetBudgetDialog() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthenticatedState) return;
    final user = authState.user;

    _budgetController.text = user.monthlyBudget.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Set Monthly Budget 💰"),
          content: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: "₹ ",
              hintText: "15000",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: PockiColors.primaryPink),
              onPressed: () {
                final amount = double.tryParse(_budgetController.text.trim());
                if (amount != null && amount > 0) {
                  context.read<ProfileBloc>().add(
                        UpdateMonthlyBudgetEvent(currentUser: user, newBudget: amount),
                      );
                  context.read<AuthBloc>().add(AuthCheckRequestedEvent());
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Monthly budget updated! 💰✨")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("👛", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                "Pocki 👛",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              const Text(
                "Your money. Your tasks. Your vibe.",
                style: TextStyle(
                  color: PockiColors.primaryPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Pocki is your cute personal lifestyle companion for daily expenses, monthly budgeting, and task productivity. ✨",
                textAlign: TextAlign.center,
                style: TextStyle(color: PockiColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: PockiColors.primaryPink),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PockiColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Settings ⚙️", style: TextStyle(color: PockiColors.textDark, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: PockiColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final budget = authState is AuthenticatedState ? authState.user.monthlyBudget : 15000.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                _buildSettingTile(
                  Icons.account_balance_wallet_outlined,
                  "Monthly Budget",
                  "₹${budget.toStringAsFixed(0)}",
                  _showSetBudgetDialog,
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  Icons.person_outline_rounded,
                  "Edit Profile",
                  "",
                  () => Navigator.pop(context),
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  Icons.lock_outline_rounded,
                  "Change Password",
                  "",
                  () {},
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  Icons.notifications_none_rounded,
                  "Notifications",
                  "On",
                  () {},
                ),
                const SizedBox(height: 12),
                _buildSettingTile(
                  Icons.info_outline_rounded,
                  "About Pocki 👛",
                  "v1.0.0",
                  _showAboutDialog,
                ),
                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutRequestedEvent());
                    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: PockiColors.pinkTint,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PockiColors.primaryPink.withValues(alpha: 0.3)),
                    ),
                    child: const Center(
                      child: Text(
                        "Logout 👋",
                        style: TextStyle(
                          color: PockiColors.primaryPink,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: PockiColors.primaryPink, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            if (value.isNotEmpty)
              Text(
                value,
                style: const TextStyle(color: PockiColors.textMuted, fontSize: 13),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: PockiColors.textMuted),
          ],
        ),
      ),
    );
  }
}
