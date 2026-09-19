import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';

class BalanceHeroCard extends StatelessWidget {
  final double availableBalance;
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;

  const BalanceHeroCard({
    super.key,
    required this.availableBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = availableBalance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE BALANCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.semanticGreenSubtle : AppColors.semanticRedSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPositive ? 'Active' : 'Deficit',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppColors.semanticGreen : AppColors.semanticRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(availableBalance),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              color: isPositive
                  ? (isDark ? Colors.white : Colors.black)
                  : AppColors.semanticRed,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Income  -  Expenses  -  Savings',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric(
                context,
                label: 'Income',
                amount: totalIncome,
                color: AppColors.semanticGreen,
              ),
              _buildVerticalDivider(isDark),
              _buildMiniMetric(
                context,
                label: 'Expenses',
                amount: totalExpenses,
                color: AppColors.semanticRed,
              ),
              _buildVerticalDivider(isDark),
              _buildMiniMetric(
                context,
                label: 'Savings',
                amount: totalSavings,
                color: AppColors.semanticAmber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 28,
      width: 1,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}
