import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData iconData = Icons.receipt_long_outlined;
    Color iconColor = isDark ? Colors.white70 : Colors.black87;
    String prefix = '';
    Color amountColor = isDark ? Colors.white : Colors.black;

    if (transaction.isExpense) {
      prefix = '-';
      amountColor = AppColors.semanticRed;
      iconData = _getCategoryIcon(transaction.category ?? '');
    } else if (transaction.isIncome) {
      prefix = '+';
      amountColor = AppColors.semanticGreen;
      iconData = Icons.arrow_downward_rounded;
    } else if (transaction.isSavings) {
      prefix = '→ ';
      amountColor = AppColors.semanticAmber;
      iconData = Icons.savings_outlined;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(iconData, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          transaction.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (transaction.isExpense && transaction.scope != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF262626) : const Color(0xFFE4E4E7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.scope == 'personal' ? 'Personal' : 'Family',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        DateFormatter.formatTime(transaction.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      if (transaction.description.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text('•', style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            transaction.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Amount
            Text(
              '$prefix${CurrencyFormatter.format(transaction.amount)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('food') || lower.contains('restaurant')) return Icons.restaurant;
    if (lower.contains('fuel') || lower.contains('petrol')) return Icons.local_gas_station;
    if (lower.contains('travel') || lower.contains('flight') || lower.contains('cab')) return Icons.directions_car;
    if (lower.contains('medical') || lower.contains('doctor') || lower.contains('health')) return Icons.medical_services_outlined;
    if (lower.contains('shopping') || lower.contains('cloth')) return Icons.shopping_bag_outlined;
    if (lower.contains('bill') || lower.contains('electric') || lower.contains('wifi')) return Icons.receipt_outlined;
    if (lower.contains('entertainment') || lower.contains('movie')) return Icons.movie_outlined;
    if (lower.contains('education') || lower.contains('school') || lower.contains('book')) return Icons.school_outlined;
    if (lower.contains('household') || lower.contains('home') || lower.contains('grocery')) return Icons.home_outlined;
    return Icons.sell_outlined;
  }
}
