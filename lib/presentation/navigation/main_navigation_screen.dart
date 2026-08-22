import 'package:flutter/material.dart';
import '../../core/theme/pocki_colors.dart';
import '../expenses/pages/expenses_screen.dart';
import '../expenses/widgets/add_expense_bottom_sheet.dart';
import '../home/pages/home_screen.dart';
import '../profile/pages/profile_screen.dart';
import '../todos/pages/todos_screen.dart';
import '../todos/widgets/add_todo_bottom_sheet.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    ExpensesScreen(),
    TodosScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  void _showAddSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Create New 👛",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddExpenseBottomSheet(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: PockiColors.pinkTint,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: PockiColors.primaryPink.withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text("💸", style: TextStyle(fontSize: 32)),
                            SizedBox(height: 8),
                            Text(
                              "Add Expense",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: PockiColors.primaryPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddTodoBottomSheet(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: PockiColors.purpleTint,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: PockiColors.secondaryPurple.withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          children: [
                            Text("🛼", style: TextStyle(fontSize: 32)),
                            SizedBox(height: 8),
                            Text(
                              "Add Next Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: PockiColors.secondaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        margin: const EdgeInsets.only(top: 24),
        child: FloatingActionButton(
          elevation: 4,
          shape: const CircleBorder(),
          backgroundColor: PockiColors.primaryPink,
          onPressed: _showAddSelectionSheet,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: PockiColors.primaryGradient,
            ),
            child: const Center(
              child: Icon(Icons.add_rounded, size: 34, color: Colors.white),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 74,
        decoration: const BoxDecoration(
          color: PockiColors.navDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, "Home"),
            _buildNavItem(1, Icons.account_balance_wallet_rounded, "Expenses"),
            const SizedBox(width: 48),
            _buildNavItem(2, Icons.skateboarding_rounded, "Next Up"),
            _buildNavItem(3, Icons.person_rounded, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? PockiColors.primaryPink : Colors.grey.shade500,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? PockiColors.primaryPink : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
