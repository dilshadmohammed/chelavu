import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/edit_transaction_sheet.dart';
import '../../widgets/transaction_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final txProv = context.watch<TransactionProvider>();
    final transactions = txProv.transactions;

    // Group transactions by Date Header
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in transactions) {
      final header = DateFormatter.formatDayHeader(tx.date);
      if (!grouped.containsKey(header)) {
        grouped[header] = [];
      }
      grouped[header]!.add(tx);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Ledger'),
      ),
      body: RefreshIndicator(
        onRefresh: () => txProv.fetchTransactions(),
        color: isDark ? Colors.white : Colors.black,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: (val) => txProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search description, category, source...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          txProv.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // Type Filter Chips: All, Expenses, Income, Savings
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip('all', 'All Types', txProv, isDark),
                  _buildTypeChip('expense', 'Expenses', txProv, isDark),
                  _buildTypeChip('income', 'Income', txProv, isDark),
                  _buildTypeChip('savings', 'Savings', txProv, isDark),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Scope Filter (Personal vs Family) if expense or all selected
            if (txProv.selectedType == 'all' || txProv.selectedType == 'expense')
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildScopeChip('all', 'All Scopes', txProv, isDark),
                    _buildScopeChip('personal', 'Personal Only', txProv, isDark),
                    _buildScopeChip('family', 'Family Only', txProv, isDark),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            if (txProv.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (transactions.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141414) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 32,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No transactions match your filter.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Grouped by Day Headers
              ...grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 6, left: 4),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ),
                    ...entry.value.map(
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
                  ],
                );
              }),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String typeKey, String label, TransactionProvider prov, bool isDark) {
    final isSelected = prov.selectedType == typeKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) prov.setTypeFilter(typeKey);
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
  }

  Widget _buildScopeChip(String scopeKey, String label, TransactionProvider prov, bool isDark) {
    final isSelected = prov.selectedScope == scopeKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) prov.setScopeFilter(scopeKey);
        },
        selectedColor: isDark ? const Color(0xFF262626) : const Color(0xFFE4E4E7),
        backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isDark ? Colors.white : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
