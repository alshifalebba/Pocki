import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/expense_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/expenses/bloc/expense_bloc.dart';

class ExpenseSummaryScreen extends StatefulWidget {
  final DateTime? initialMonth;

  const ExpenseSummaryScreen({super.key, this.initialMonth});

  @override
  State<ExpenseSummaryScreen> createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final init = widget.initialMonth ?? DateTime.now();
    _selectedMonth = DateTime(init.year, init.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: PockiColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: PockiColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("📊 ", style: TextStyle(fontSize: 20)),
            Text("Expense Summary", style: TextStyle(color: PockiColors.textDark, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthenticatedState) {
              return const Center(child: CircularProgressIndicator());
            }

            return BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, expenseState) {
                List<ExpenseEntity> allExpenses = [];
                if (expenseState is ExpenseLoadedState) {
                  allExpenses = expenseState.expenses;
                }

                // Filter expenses for selected month
                final monthExpenses = allExpenses.where((e) {
                  return e.dateTime.year == _selectedMonth.year &&
                      e.dateTime.month == _selectedMonth.month;
                }).toList();

                final monthTotalSpent = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

                // Group expenses by category
                final Map<String, _CategoryGroup> grouped = {};
                for (final e in monthExpenses) {
                  final catName = e.category == ExpenseCategory.other && e.otherDetails != null && e.otherDetails!.isNotEmpty
                      ? e.otherDetails!
                      : e.category.displayName;
                  final emoji = e.category.emoji;

                  if (grouped.containsKey(catName)) {
                    grouped[catName]!.totalAmount += e.amount;
                    grouped[catName]!.count += 1;
                  } else {
                    grouped[catName] = _CategoryGroup(
                      name: catName,
                      emoji: emoji,
                      totalAmount: e.amount,
                      count: 1,
                    );
                  }
                }

                final categoryList = grouped.values.toList()
                  ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Selector Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _previousMonth,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: PockiColors.pinkTint,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: PockiColors.primaryPink),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_rounded, size: 18, color: PockiColors.primaryPink),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMMM yyyy').format(_selectedMonth),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: PockiColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _nextMonth,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: PockiColors.pinkTint,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.arrow_forward_ios, size: 16, color: PockiColors.primaryPink),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Month Total Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: PockiColors.cardGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: PockiColors.primaryPink.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text("💸 ", style: TextStyle(fontSize: 18)),
                                Text(
                                  "Total Spent This Month",
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currencyFormat.format(monthTotalSpent),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              monthExpenses.isEmpty
                                  ? "No expenses recorded"
                                  : "${monthExpenses.length} transactions across ${categoryList.length} categories",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.87), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category Breakdown Header
                      const Text(
                        "Category Breakdown",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                      ),
                      const SizedBox(height: 12),

                      if (monthExpenses.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              const Text("✨", style: TextStyle(fontSize: 44)),
                              const SizedBox(height: 12),
                              Text(
                                "No expenses yet for ${DateFormat('MMMM yyyy').format(_selectedMonth)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: PockiColors.textDark),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Your wallet is staying relaxed! 😌",
                                style: TextStyle(fontSize: 12, color: PockiColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categoryList.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final cat = categoryList[index];
                            final percentage = monthTotalSpent > 0
                                ? (cat.totalAmount / monthTotalSpent * 100)
                                : 0.0;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: PockiColors.pinkTint,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cat.name,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${cat.count} transaction${cat.count > 1 ? 's' : ''}",
                                              style: const TextStyle(fontSize: 11, color: PockiColors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            currencyFormat.format(cat.totalAmount),
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: PockiColors.purpleTint,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              "${percentage.toStringAsFixed(1)}%",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: PockiColors.secondaryPurple,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Progress Bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: (percentage / 100).clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: const AlwaysStoppedAnimation<Color>(PockiColors.primaryPink),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 24),
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
}

class _CategoryGroup {
  final String name;
  final String emoji;
  double totalAmount;
  int count;

  _CategoryGroup({
    required this.name,
    required this.emoji,
    required this.totalAmount,
    required this.count,
  });
}
