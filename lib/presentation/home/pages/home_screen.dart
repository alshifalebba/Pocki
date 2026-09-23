import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/expense_entity.dart';
import 'package:pocki/domain/entities/fixed_expense_entity.dart';
import 'package:pocki/domain/entities/additional_amount_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/expenses/bloc/expense_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      context.read<ExpenseBloc>().add(LoadExpensesEvent(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: PockiColors.lightBackground,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthenticatedState) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = authState.user;

            return BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, expenseState) {
                List<ExpenseEntity> expenses = [];
                List<FixedExpenseEntity> fixedExpenses = [];
                List<AdditionalAmountEntity> additionalAmounts = [];
                if (expenseState is ExpenseLoadedState) {
                  expenses = expenseState.expenses;
                  fixedExpenses = expenseState.fixedExpenses;
                  additionalAmounts = expenseState.additionalAmounts;
                }

                // Dynamic Calculations
                final now = DateTime.now();
                final monthlyExpenses = expenses.where(
                  (e) => e.dateTime.year == now.year && e.dateTime.month == now.month,
                );
                final totalRegularSpent = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);
                final totalFixedSpent = fixedExpenses.fold(0.0, (sum, f) => sum + f.amount);
                final totalSpent = totalRegularSpent + totalFixedSpent;
                final totalAdditional = additionalAmounts.fold(0.0, (sum, a) => sum + a.amount);
                final totalBudget = user.monthlyBudget + totalAdditional;
                final remaining = totalBudget - totalSpent;

                final lastDay = DateTime(now.year, now.month + 1, 0).day;
                final daysLeft = (lastDay - now.day) + 1;
                final safeDaily = daysLeft > 0 && remaining > 0 ? remaining / daysLeft : 0.0;

                final todayExpenses = expenses.where(
                  (e) =>
                      e.dateTime.year == now.year &&
                      e.dateTime.month == now.month &&
                      e.dateTime.day == now.day,
                );
                final todaySpent = todayExpenses.fold(0.0, (sum, e) => sum + e.amount);
                final dailyAvg = now.day > 0 ? totalRegularSpent / now.day : 0.0;

                double usedPercentage = (totalSpent / totalBudget).clamp(0.0, 1.0);
                int percentageInt = (usedPercentage * 100).round();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 22,
                                backgroundColor: PockiColors.pinkTint,
                                child: Text("👩🏻‍💼", style: TextStyle(fontSize: 24)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Heyy, ${user.name.split(' ').first}! ",
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const Text("👋", style: TextStyle(fontSize: 18)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "Let's crush your goals today ✨",
                                    style: TextStyle(
                                      color: PockiColors.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.notifications_none_rounded, size: 22, color: PockiColors.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Monthly Budget Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: PockiColors.primaryPink.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Monthly Budget",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: PockiColors.textDark,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: PockiColors.purpleTint,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        DateFormat('MMM yyyy').format(now),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: PockiColors.secondaryPurple,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.keyboard_arrow_down, size: 16, color: PockiColors.secondaryPurple),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 58.0,
                                  lineWidth: 12.0,
                                  percent: usedPercentage,
                                  center: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$percentageInt%",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: PockiColors.textDark,
                                        ),
                                      ),
                                      const Text(
                                        "of budget used",
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: PockiColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text("😍", style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  linearGradient: PockiColors.primaryGradient,
                                  backgroundColor: const Color(0xFFF2EAF8),
                                  circularStrokeCap: CircularStrokeCap.round,
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Total Budget",
                                        style: TextStyle(fontSize: 12, color: PockiColors.textMuted),
                                      ),
                                      Text(
                                        currencyFormat.format(totalBudget),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: PockiColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Used",
                                        style: TextStyle(fontSize: 12, color: PockiColors.textMuted),
                                      ),
                                      Text(
                                        currencyFormat.format(totalSpent),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: PockiColors.primaryPink,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Left to Spend",
                                        style: TextStyle(fontSize: 12, color: PockiColors.textMuted),
                                      ),
                                      Text(
                                        currencyFormat.format(remaining),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: PockiColors.successGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Mascot Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: PockiColors.mascotBannerGradient,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: PockiColors.primaryPink.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "You can spend",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: PockiColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    remaining < 0
                                        ? "Over budget! 😭"
                                        : "${currencyFormat.format(safeDaily.round())}/day 💸",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: PockiColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "for the rest of this month ($daysLeft days left)",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: PockiColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'assets/illustrations/mascot.png',
                              height: 70,
                              width: 70,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text("🦖✨", style: TextStyle(fontSize: 48));
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Summary Stats Pills
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryPill(
                              "Today's Expense",
                              currencyFormat.format(todaySpent),
                              "📦",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryPill(
                              "This Month",
                              currencyFormat.format(totalSpent),
                              "📈",
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryPill(
                              "Daily Avg",
                              currencyFormat.format(dailyAvg.round()),
                              "📊",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Expenses
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Recent Expenses",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: PockiColors.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/expenses'),
                            child: const Text(
                              "See All",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: PockiColors.secondaryPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (expenses.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            children: [
                              Text("🌱", style: TextStyle(fontSize: 32)),
                              SizedBox(height: 8),
                              Text("No expenses yet. Your wallet is behaving 😌", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: expenses.take(4).length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = expenses[index];
                            return _buildExpenseTile(item, currencyFormat);
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryPill(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: PockiColors.textMuted, fontWeight: FontWeight.bold),
                ),
              ),
              Text(emoji, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PockiColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(ExpenseEntity expense, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PockiColors.pinkTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(expense.category.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category == ExpenseCategory.other && expense.otherDetails != null
                      ? expense.otherDetails!
                      : expense.category.displayName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  "Today • ${expense.timeString}",
                  style: const TextStyle(fontSize: 11, color: PockiColors.textMuted),
                ),
              ],
            ),
          ),
          Text(
            format.format(expense.amount),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: PockiColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
