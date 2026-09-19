import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/add_expense_sheet.dart';
import '../../widgets/add_income_sheet.dart';
import '../../widgets/add_savings_sheet.dart';
import '../../widgets/balance_hero_card.dart';
import '../../widgets/edit_transaction_sheet.dart';
import '../../widgets/scope_progress_bar.dart';
import '../../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<ReportProvider>().fetchSummary(),
      context.read<CategoryProvider>().fetchCategories(),
      context.read<TransactionProvider>().fetchTransactions(),
    ]);
  }

  void _showAddExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddExpenseSheet(),
    );
  }

  void _showAddIncome() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddIncomeSheet(),
    );
  }

  void _showAddSavings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddSavingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportProv = context.watch<ReportProvider>();
    final summary = reportProv.summary;
    final authProv = context.watch<AuthProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: isDark ? Colors.white : Colors.black,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // User Greeting / Top Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${authProv.user?.name ?? "User"}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chelavu Financial Ledger',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                if (authProv.isDemoMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262626) : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Demo Mode',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero Available Balance Card
            BalanceHeroCard(
              availableBalance: summary.availableBalance,
              totalIncome: summary.totalIncome,
              totalExpenses: summary.totalExpenses,
              totalSavings: summary.totalSavings,
            ),
            const SizedBox(height: 16),

            // Quick Actions: + Expense, + Income, + Savings
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    label: '+ Expense',
                    onTap: _showAddExpense,
                    isPrimary: true,
                    color: AppColors.semanticRed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    label: '+ Income',
                    onTap: _showAddIncome,
                    isPrimary: false,
                    color: AppColors.semanticGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    label: '+ Savings',
                    onTap: _showAddSavings,
                    isPrimary: false,
                    color: AppColors.semanticAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Personal vs Family Spending Progress Bar
            ScopeProgressBar(
              personalAmount: summary.personalExpenses,
              familyAmount: summary.familyExpenses,
            ),
            const SizedBox(height: 20),

            // Today's Glance Header & Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Expenses",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Spent: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(summary.todaySpending),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: summary.todaySpending > 0 ? AppColors.semanticRed : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // List of Today's Expenses
            if (summary.todayExpenses.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141414) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 28,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No expenses recorded yet today.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...summary.todayExpenses.map(
                (tx) => TransactionTile(
                  transaction: tx,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => EditTransactionSheet(transaction: tx),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // Recent Transactions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (summary.recentTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141414) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  'No recent transactions.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              )
            else
              ...summary.recentTransactions.map(
                (tx) => TransactionTile(
                  transaction: tx,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => EditTransactionSheet(transaction: tx),
                    );
                  },
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF4F4F5)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isPrimary
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
