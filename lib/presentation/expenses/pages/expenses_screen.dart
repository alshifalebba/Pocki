import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pocki/core/theme/pocki_colors.dart';
import 'package:pocki/domain/entities/expense_entity.dart';
import 'package:pocki/domain/entities/fixed_expense_entity.dart';
import 'package:pocki/domain/entities/user_entity.dart';
import 'package:pocki/presentation/auth/bloc/auth_bloc.dart';
import 'package:pocki/presentation/expenses/bloc/expense_bloc.dart';
import 'package:pocki/presentation/profile/bloc/profile_bloc.dart';
import '../widgets/add_expense_bottom_sheet.dart';
import '../widgets/add_fixed_expense_bottom_sheet.dart';
import 'expense_summary_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedCategoryFilter = 'All';
  DateTime? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      context.read<ExpenseBloc>().add(LoadExpensesEvent(authState.user.uid));
    }
  }

  Future<void> _pickDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PockiColors.primaryPink,
              onPrimary: Colors.white,
              onSurface: PockiColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateFilter = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateFilter = null;
    });
  }

  void _editBudgetDialog(UserEntity user) {
    final controller = TextEditingController(text: user.monthlyBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Text("Edit Monthly Budget "),
              Text("💰", style: TextStyle(fontSize: 20)),
            ],
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: "Enter monthly budget amount (₹)",
              prefixText: "₹ ",
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
                final text = controller.text.trim();
                final parsed = double.tryParse(text);
                if (parsed != null && parsed >= 0) {
                  final updatedUser = user.copyWith(monthlyBudget: parsed, updatedAt: DateTime.now());
                  context.read<ProfileBloc>().add(
                        UpdateMonthlyBudgetEvent(currentUser: user, newBudget: parsed),
                      );
                  context.read<AuthBloc>().add(UpdateAuthUserEvent(updatedUser));
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Monthly budget updated! 💰✨")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid positive number"),
                      backgroundColor: PockiColors.errorRed,
                    ),
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

  void _openAddExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddExpenseBottomSheet(),
    );
  }

  void _openAddFixedExpense({FixedExpenseEntity? itemToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFixedExpenseBottomSheet(fixedExpenseToEdit: itemToEdit),
    );
  }

  void _confirmDeleteFixedExpense(String userId, FixedExpenseEntity item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Delete fixed expense?"),
          content: Text("Are you sure you want to remove '${item.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: PockiColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PockiColors.errorRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                context.read<ExpenseBloc>().add(
                      DeleteFixedExpenseSubmittedEvent(
                        userId: userId,
                        fixedExpenseId: item.id,
                      ),
                    );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fixed expense deleted 🗑️")),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
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

                if (expenseState is ExpenseLoadedState) {
                  expenses = expenseState.expenses;
                  fixedExpenses = expenseState.fixedExpenses;
                }

                final now = DateTime.now();
                // Regular expenses for CURRENT month only
                final currentMonthExpenses = expenses.where(
                  (e) => e.dateTime.year == now.year && e.dateTime.month == now.month,
                );
                final totalRegularSpent = currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
                final totalFixedSpent = fixedExpenses.fold(0.0, (sum, f) => sum + f.amount);
                final totalCombinedSpent = totalRegularSpent + totalFixedSpent;
                final remaining = user.monthlyBudget - totalCombinedSpent;

                // Filtering regular expenses for current month or date filter
                List<ExpenseEntity> filteredExpenses = expenses;

                if (_selectedDateFilter != null) {
                  filteredExpenses = filteredExpenses.where((e) {
                    return e.dateTime.year == _selectedDateFilter!.year &&
                        e.dateTime.month == _selectedDateFilter!.month &&
                        e.dateTime.day == _selectedDateFilter!.day;
                  }).toList();
                } else {
                  // Default to current month when no specific date filter is selected
                  filteredExpenses = filteredExpenses.where((e) {
                    return e.dateTime.year == now.year && e.dateTime.month == now.month;
                  }).toList();
                }

                if (_selectedCategoryFilter != 'All') {
                  filteredExpenses = filteredExpenses
                      .where((e) => e.category.displayName.toLowerCase() == _selectedCategoryFilter.toLowerCase())
                      .toList();
                }

                // Previous Months Computation
                final currentMonthKey = DateTime(now.year, now.month);
                final Map<DateTime, List<ExpenseEntity>> previousMonthsMap = {};
                for (final e in expenses) {
                  final mKey = DateTime(e.dateTime.year, e.dateTime.month);
                  if (mKey.isBefore(currentMonthKey)) {
                    previousMonthsMap.putIfAbsent(mKey, () => []).add(e);
                  }
                }
                final previousMonthKeys = previousMonthsMap.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return Column(
                  children: [
                    // Top Bar with Summary & Calendar Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("💸", style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text("Expenses", style: Theme.of(context).textTheme.headlineMedium),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ExpenseSummaryScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.analytics_outlined,
                                    size: 20,
                                    color: PockiColors.secondaryPurple,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _pickDateFilter,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _selectedDateFilter != null ? PockiColors.pinkTint : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _selectedDateFilter != null ? PockiColors.primaryPink : Colors.transparent,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    size: 20,
                                    color: _selectedDateFilter != null ? PockiColors.primaryPink : PockiColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Filter Banner if Active
                            if (_selectedDateFilter != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: PockiColors.pinkTint,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: PockiColors.primaryPink.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.filter_alt_rounded, size: 16, color: PockiColors.primaryPink),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Filtering: ${DateFormat('d MMM yyyy').format(_selectedDateFilter!)}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: PockiColors.primaryPink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _clearDateFilter,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.close_rounded, size: 14, color: PockiColors.primaryPink),
                                            SizedBox(width: 4),
                                            Text(
                                              "Clear",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: PockiColors.primaryPink,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            Row(
                              children: [
                                Text(
                                  DateFormat('MMMM yyyy').format(now),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: PockiColors.textDark),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Gradient Budget Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                gradient: PockiColors.cardGradient,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Monthly Budget",
                                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      GestureDetector(
                                        onTap: () => _editBudgetDialog(user),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "Edit",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(user.monthlyBudget),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Regular Used", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                          const SizedBox(height: 2),
                                          Text(
                                            currencyFormat.format(totalRegularSpent),
                                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Text("Fixed", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                          const SizedBox(height: 2),
                                          Text(
                                            currencyFormat.format(totalFixedSpent),
                                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          const Text("Left", style: TextStyle(color: Colors.white70, fontSize: 11)),
                                          const SizedBox(height: 2),
                                          Text(
                                            currencyFormat.format(remaining),
                                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // FIXED EXPENSES SECTION WITH DECORATIVE ILLUSTATION & BADGE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: PockiColors.purpleTint,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Image.asset(
                                        'assets/illustrations/mascot.png',
                                        height: 22,
                                        width: 22,
                                        errorBuilder: (ctx, err, stack) => const Text("🐷", style: TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Fixed Expenses",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: PockiColors.pinkTint,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "Monthly 💳",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PockiColors.primaryPink),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => _openAddFixedExpense(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: PockiColors.purpleTint,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.add_rounded, size: 16, color: PockiColors.secondaryPurple),
                                        SizedBox(width: 4),
                                        Text(
                                          "Add Fixed",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: PockiColors.secondaryPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (fixedExpenses.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Text("💡", style: TextStyle(fontSize: 24)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "No fixed expenses set (e.g. Rent, Netflix, Internet). Tap '+ Add Fixed' to set them up!",
                                        style: TextStyle(fontSize: 12, color: PockiColors.textMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: fixedExpenses.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final item = fixedExpenses[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: PockiColors.purpleTint,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                            Icons.autorenew_rounded,
                                            color: PockiColors.secondaryPurple,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                item.category,
                                                style: const TextStyle(fontSize: 11, color: PockiColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          currencyFormat.format(item.amount),
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () => _openAddFixedExpense(itemToEdit: item),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(Icons.edit_outlined, size: 18, color: PockiColors.secondaryPurple),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => _confirmDeleteFixedExpense(user.uid, item),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(Icons.delete_outline_rounded, size: 18, color: PockiColors.errorRed),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 24),

                            // REGULAR EXPENSE LIST SECTION
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Expense List",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                                    ),
                                    if (_selectedCategoryFilter != 'All' || _selectedDateFilter != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: PockiColors.pinkTint,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          currencyFormat.format(filteredExpenses.fold(0.0, (sum, e) => sum + e.amount)),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: PockiColors.primaryPink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _openAddExpense,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: PockiColors.navDark,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Category Filters
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ['All', 'Food', 'Transport', 'Petrol', 'Groceries', 'Dress', 'Other'].map((cat) {
                                  final isSelected = _selectedCategoryFilter == cat;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedCategoryFilter = cat),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? PockiColors.navDark : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : PockiColors.textDark,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (filteredExpenses.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(32),
                                width: double.infinity,
                                child: Column(
                                  children: [
                                    const Text("💸🌱", style: TextStyle(fontSize: 40)),
                                    const SizedBox(height: 12),
                                    Text(
                                      _selectedDateFilter != null
                                          ? "No expenses found for ${DateFormat('d MMM yyyy').format(_selectedDateFilter!)}"
                                          : "No expenses yet. Your wallet is behaving 😌",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredExpenses.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = filteredExpenses[index];
                                  return Dismissible(
                                    key: Key(item.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: PockiColors.errorRed,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                                    ),
                                    onDismissed: (direction) {
                                      context.read<ExpenseBloc>().add(
                                            DeleteExpenseSubmittedEvent(
                                              userId: user.uid,
                                              expenseId: item.id,
                                            ),
                                          );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Expense deleted 🗑️")),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: PockiColors.pinkTint,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Text(item.category.emoji, style: const TextStyle(fontSize: 24)),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.category == ExpenseCategory.other && item.otherDetails != null
                                                      ? item.otherDetails!
                                                      : item.category.displayName,
                                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "${DateFormat('d MMM').format(item.dateTime)} • ${item.timeString}",
                                                  style: const TextStyle(fontSize: 11, color: PockiColors.textMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            currencyFormat.format(item.amount),
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                            // PREVIOUS MONTHS SECTION
                            if (previousMonthKeys.isNotEmpty) ...[
                              const SizedBox(height: 28),
                              const Row(
                                children: [
                                  Text("📦", style: TextStyle(fontSize: 18)),
                                  SizedBox(width: 6),
                                  Text(
                                    "Previous Months",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: previousMonthKeys.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final mKey = previousMonthKeys[index];
                                  final mExpenses = previousMonthsMap[mKey]!;
                                  final totalSpent = mExpenses.fold(0.0, (sum, e) => sum + e.amount);
                                  final catCount = mExpenses.map((e) => e.category).toSet().length;

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ExpenseSummaryScreen(initialMonth: mKey),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.02),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: PockiColors.pinkTint,
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: const Text("📦", style: TextStyle(fontSize: 20)),
                                              ),
                                              const SizedBox(width: 14),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    DateFormat('MMMM yyyy').format(mKey),
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: PockiColors.textDark),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "$catCount categor${catCount > 1 ? 'ies' : 'y'} • ${currencyFormat.format(totalSpent)}",
                                                    style: const TextStyle(fontSize: 11, color: PockiColors.textMuted),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Row(
                                            children: [
                                              Text(
                                                "Summary",
                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PockiColors.primaryPink),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: PockiColors.primaryPink),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
