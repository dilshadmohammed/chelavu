import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/report_provider.dart';
import '../../widgets/scope_progress_bar.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchMonthlyOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportProv = context.watch<ReportProvider>();
    final monthly = reportProv.monthlyOverview;
    final currentYear = reportProv.selectedYear;
    final currentMonth = reportProv.selectedMonth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Overview'),
      ),
      body: RefreshIndicator(
        onRefresh: () => reportProv.fetchMonthlyOverview(),
        color: isDark ? Colors.white : Colors.black,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Month Switcher Bar (< September 2026 >)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141414) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 22),
                    onPressed: reportProv.prevMonth,
                    tooltip: 'Previous Month',
                  ),
                  Text(
                    '${_monthNames[currentMonth - 1]} $currentYear',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 22),
                    onPressed: reportProv.nextMonth,
                    tooltip: 'Next Month',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (reportProv.isMonthlyLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (monthly == null)
              const Center(child: Text('No data for this month'))
            else ...[
              // Available Balance for the Month
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141414) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY NET BALANCE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(monthly.availableBalance),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: monthly.availableBalance >= 0
                            ? (isDark ? Colors.white : Colors.black)
                            : AppColors.semanticRed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Income - Expenses - Savings',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricCol('Income', monthly.totalIncome, AppColors.semanticGreen, isDark),
                        _buildMetricCol('Expenses', monthly.totalExpenses, AppColors.semanticRed, isDark),
                        _buildMetricCol('Savings', monthly.totalSavings, AppColors.semanticAmber, isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Personal vs Family spending for the month
              ScopeProgressBar(
                personalAmount: monthly.personalExpenses,
                familyAmount: monthly.familyExpenses,
              ),
              const SizedBox(height: 20),

              // Category-Wise Spending for the Month
              Text(
                'Category Breakdown (${_monthNames[currentMonth - 1]})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              if (monthly.categories.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141414) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    'No expenses recorded in ${_monthNames[currentMonth - 1]}.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              else
                ...monthly.categories.map((cat) {
                  final ratio = monthly.totalExpenses > 0 ? (cat.total / monthly.totalExpenses) : 0.0;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141414) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cat.category,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  CurrencyFormatter.format(cat.total),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF262626) : const Color(0xFFF4F4F5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${cat.percentage}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 5,
                            backgroundColor: isDark ? const Color(0xFF262626) : const Color(0xFFE4E4E7),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${cat.count} transaction${cat.count == 1 ? "" : "s"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, double amount, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          CurrencyFormatter.format(amount),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
