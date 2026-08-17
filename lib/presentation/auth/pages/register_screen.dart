import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/pocki_colors.dart';
import '../bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _onRegisterPressed() {
    final fullName = _fullNameController.text.trim();
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || nickname.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields! ✨"),
          backgroundColor: PockiColors.errorRed,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterSubmittedEvent(
            name: fullName,
            nickname: nickname,
            email: email,
            phone: _phoneController.text.trim(),
            password: password,
          ),
        );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: PockiColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: PockiColors.errorRed,
              ),
            );
          } else if (state is AuthenticatedState) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Join Pocki ",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Text("👛✨", style: TextStyle(fontSize: 28)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Your money. Your tasks. Your vibe.",
                  style: TextStyle(
                    color: PockiColors.primaryPink,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  "Full Name",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: "e.g. Alex Johnson",
                    prefixIcon: Icon(Icons.person_outline_rounded, color: PockiColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Nickname",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: "e.g. alex_j",
                    prefixIcon: Icon(Icons.alternate_email_rounded, color: PockiColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Email",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "your.email@example.com",
                    prefixIcon: Icon(Icons.email_outlined, color: PockiColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Phone",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "+1 234 567 8900",
                    prefixIcon: Icon(Icons.phone_outlined, color: PockiColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Password",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: PockiColors.textMuted),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: PockiColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: PockiColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoadingState;
                    return GestureDetector(
                      onTap: isLoading ? null : _onRegisterPressed,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: PockiColors.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: PockiColors.primaryPink.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
