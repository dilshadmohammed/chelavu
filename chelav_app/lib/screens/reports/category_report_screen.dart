import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/report_provider.dart';

class CategoryReportScreen extends StatefulWidget {
  const CategoryReportScreen({super.key});

  @override
  State<CategoryReportScreen> createState() => _CategoryReportScreenState();
}

class _CategoryReportScreenState extends State<CategoryReportScreen> {
  final List<Map<String, String>> _ranges = [
    {'label': 'Today', 'key': 'today'},
    {'label': 'This Week', 'key': 'week'},
    {'label': 'This Month', 'key': 'month'},
    {'label': 'Last Month', 'key': 'last_month'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchCategoryReport();
    });
  }

  Future<void> _pickCustomDateRange() async {
    final reportProv = context.read<ReportProvider>();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      reportProv.fetchCategoryReport(
        range: 'custom',
        from: range.start.toIso8601String().split('T')[0],
        to: range.end.toIso8601String().split('T')[0],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportProv = context.watch<ReportProvider>();
    final catReport = reportProv.categoryReport;
    final selectedRange = reportProv.selectedCategoryRange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: _pickCustomDateRange,
            tooltip: 'Custom Date Range',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => reportProv.fetchCategoryReport(),
        color: isDark ? Colors.white : Colors.black,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Scope Selector Chips (All, Personal, Family)
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFE4E4E7),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  _buildScopeSegment('all', 'All Spending', isDark, reportProv),
                  _buildScopeSegment('personal', 'Personal', isDark, reportProv),
                  _buildScopeSegment('family', 'Family', isDark, reportProv),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Time Range Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._ranges.map((r) {
                    final isSelected = selectedRange == r['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(r['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            reportProv.fetchCategoryReport(range: r['key']);
                          }
                        },
                        selectedColor: isDark ? Colors.white : Colors.black,
                        backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? (isDark ? Colors.white : Colors.black)
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12),
                          SizedBox(width: 4),
                          Text('Custom'),
                        ],
                      ),
                      selected: selectedRange == 'custom',
                      onSelected: (_) => _pickCustomDateRange(),
                      selectedColor: isDark ? Colors.white : Colors.black,
                      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: selectedRange == 'custom' ? FontWeight.w600 : FontWeight.w400,
                        color: selectedRange == 'custom'
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: selectedRange == 'custom'
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (reportProv.isCategoryLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (catReport == null)
              const Center(child: Text('No data found.'))
            else ...[
              // Total Spending Hero Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL SPENT IN PERIOD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(catReport.totalSpending),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: catReport.totalSpending > 0
                                ? AppColors.semanticRed
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262626) : const Color(0xFFE4E4E7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${catReport.categories.length} Categories',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Ranked Categories',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),

              if (catReport.categories.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141414) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    'No expenses found in this time range.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              else
                ...catReport.categories.map((cat) {
                  final ratio = catReport.totalSpending > 0 ? (cat.total / catReport.totalSpending) : 0.0;
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
                            minHeight: 6,
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

  Widget _buildScopeSegment(
    String scopeKey,
    String label,
    bool isDark,
    ReportProvider prov,
  ) {
    final isSelected = prov.selectedCategoryScope == scopeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => prov.fetchCategoryReport(scope: scopeKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
