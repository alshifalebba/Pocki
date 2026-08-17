import 'package:flutter/material.dart';
import '../../../core/theme/pocki_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: PockiColors.purpleTint,
                  shape: BoxShape.circle,
                  border: Border.all(color: PockiColors.lavender, width: 3),
                ),
                child: const Center(
                  child: Text("👛✨", style: TextStyle(fontSize: 54)),
                ),
              ),
              const SizedBox(height: 32),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Meet Pocki ",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const TextSpan(
                      text: "👛",
                      style: TextStyle(fontSize: 28),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your money. Your tasks. Your vibe.",
                style: TextStyle(
                  color: PockiColors.primaryPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Track your spending, manage your budget, and stay on top of your tasks — all in one cute little place. ✨",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PockiColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/register');
                },
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
                  child: const Center(
                    child: Text(
                      "Get Started",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/login');
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: PockiColors.lavender, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      "I already have an account",
                      style: TextStyle(
                        color: PockiColors.secondaryPurple,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
