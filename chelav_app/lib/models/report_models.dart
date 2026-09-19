import 'transaction_model.dart';

class DashboardSummary {
  final double availableBalance;
  final double totalIncome;
  final double totalExpenses;
  final double totalSavings;
  final double personalExpenses;
  final double familyExpenses;
  final double todaySpending;
  final List<TransactionModel> todayExpenses;
  final List<TransactionModel> recentTransactions;

  DashboardSummary({
    required this.availableBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSavings,
    required this.personalExpenses,
    required this.familyExpenses,
    required this.todaySpending,
    required this.todayExpenses,
    required this.recentTransactions,
  });

  factory DashboardSummary.initial() {
    return DashboardSummary(
      availableBalance: 0,
      totalIncome: 0,
      totalExpenses: 0,
      totalSavings: 0,
      personalExpenses: 0,
      familyExpenses: 0,
      todaySpending: 0,
      todayExpenses: [],
      recentTransactions: [],
    );
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0.0,
      personalExpenses: (json['personalExpenses'] as num?)?.toDouble() ?? 0.0,
      familyExpenses: (json['familyExpenses'] as num?)?.toDouble() ?? 0.0,
      todaySpending: (json['todaySpending'] as num?)?.toDouble() ?? 0.0,
      todayExpenses: (json['todayExpenses'] as List?)
              ?.map((t) => TransactionModel.fromJson(t))
              .toList() ??
          [],
      recentTransactions: (json['recentTransactions'] as List?)
              ?.map((t) => TransactionModel.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class CategorySpendItem {
  final String category;
  final double total;
  final int count;
  final double personal;
  final double family;

  CategorySpendItem({
    required this.category,
    required this.total,
    required this.count,
    required this.personal,
    required this.family,
  });

  factory CategorySpendItem.fromJson(Map<String, dynamic> json) {
    return CategorySpendItem(
      category: json['category'] ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      personal: (json['personal'] as num?)?.toDouble() ?? 0.0,
      family: (json['family'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyReport {
  final String date;
  final double dayIncome;
  final double dayExpenses;
  final double daySavings;
  final double dayBalance;
  final double personalExpenses;
  final double familyExpenses;
  final List<CategorySpendItem> categories;
  final List<TransactionModel> transactions;

  DailyReport({
    required this.date,
    required this.dayIncome,
    required this.dayExpenses,
    required this.daySavings,
    required this.dayBalance,
    required this.personalExpenses,
    required this.familyExpenses,
    required this.categories,
    required this.transactions,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      date: json['date'] ?? '',
      dayIncome: (json['dayIncome'] as num?)?.toDouble() ?? 0.0,
      dayExpenses: (json['dayExpenses'] as num?)?.toDouble() ?? 0.0,
      daySavings: (json['daySavings'] as num?)?.toDouble() ?? 0.0,
      dayBalance: (json['dayBalance'] as num?)?.toDouble() ?? 0.0,
      personalExpenses: (json['personalExpenses'] as num?)?.toDouble() ?? 0.0,
      familyExpenses: (json['familyExpenses'] as num?)?.toDouble() ?? 0.0,
      categories: (json['categories'] as List?)
              ?.map((c) => CategorySpendItem.fromJson(c))
              .toList() ??
          [],
      transactions: (json['transactions'] as List?)
              ?.map((t) => TransactionModel.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class CategoryShareItem {
  final String category;
  final double total;
  final int count;
  final double percentage;

  CategoryShareItem({
    required this.category,
    required this.total,
    required this.count,
    required this.percentage,
  });

  factory CategoryShareItem.fromJson(Map<String, dynamic> json) {
    return CategoryShareItem(
      category: json['category'] ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryReport {
  final String range;
  final String scope;
  final double totalSpending;
  final List<CategoryShareItem> categories;

  CategoryReport({
    required this.range,
    required this.scope,
    required this.totalSpending,
    required this.categories,
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      range: json['range'] ?? 'month',
      scope: json['scope'] ?? 'all',
      totalSpending: (json['totalSpending'] as num?)?.toDouble() ?? 0.0,
      categories: (json['categories'] as List?)
              ?.map((c) => CategoryShareItem.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class MonthlyOverview {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpenses;
  final double personalExpenses;
  final double familyExpenses;
  final double totalSavings;
  final double availableBalance;
  final List<CategoryShareItem> categories;

  MonthlyOverview({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.personalExpenses,
    required this.familyExpenses,
    required this.totalSavings,
    required this.availableBalance,
    required this.categories,
  });

  factory MonthlyOverview.fromJson(Map<String, dynamic> json) {
    return MonthlyOverview(
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      personalExpenses: (json['personalExpenses'] as num?)?.toDouble() ?? 0.0,
      familyExpenses: (json['familyExpenses'] as num?)?.toDouble() ?? 0.0,
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      categories: (json['categories'] as List?)
              ?.map((c) => CategoryShareItem.fromJson(c))
              .toList() ??
          [],
    );
  }
}
