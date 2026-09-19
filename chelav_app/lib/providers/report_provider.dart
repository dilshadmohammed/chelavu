import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/utils/date_formatter.dart';
import '../models/report_models.dart';
import '../models/transaction_model.dart';

class ReportProvider extends ChangeNotifier {
  final ApiClient apiClient;

  DashboardSummary _summary = DashboardSummary.initial();
  DailyReport? _dailyReport;
  CategoryReport? _categoryReport;
  MonthlyOverview? _monthlyOverview;

  DateTime _selectedDailyDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String _selectedCategoryRange = 'month';
  String _selectedCategoryScope = 'all';

  bool _isSummaryLoading = false;
  bool _isDailyLoading = false;
  bool _isCategoryLoading = false;
  bool _isMonthlyLoading = false;

  DashboardSummary get summary => _summary;
  DailyReport? get dailyReport => _dailyReport;
  CategoryReport? get categoryReport => _categoryReport;
  MonthlyOverview? get monthlyOverview => _monthlyOverview;

  DateTime get selectedDailyDate => _selectedDailyDate;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  String get selectedCategoryRange => _selectedCategoryRange;
  String get selectedCategoryScope => _selectedCategoryScope;

  bool get isSummaryLoading => _isSummaryLoading;
  bool get isDailyLoading => _isDailyLoading;
  bool get isCategoryLoading => _isCategoryLoading;
  bool get isMonthlyLoading => _isMonthlyLoading;

  ReportProvider({required this.apiClient});

  Future<void> fetchSummary() async {
    _isSummaryLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get('/reports/summary');
      if (res['success'] == true && res['data'] != null) {
        _summary = DashboardSummary.fromJson(res['data']);
      }
    } catch (e) {
      debugPrint('[ReportProvider fetchSummary Error] $e');
    } finally {
      _isSummaryLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyReport([DateTime? date]) async {
    if (date != null) {
      _selectedDailyDate = date;
    }
    _isDailyLoading = true;
    notifyListeners();

    try {
      final dateStr = DateFormatter.toIsoDate(_selectedDailyDate);
      final res = await apiClient.get('/reports/daily', queryParams: {'date': dateStr});
      if (res['success'] == true && res['data'] != null) {
        _dailyReport = DailyReport.fromJson(res['data']);
      }
    } catch (e) {
      debugPrint('[ReportProvider fetchDailyReport Error] $e');
    } finally {
      _isDailyLoading = false;
      notifyListeners();
    }
  }

  void nextDay() {
    _selectedDailyDate = _selectedDailyDate.add(const Duration(days: 1));
    fetchDailyReport(_selectedDailyDate);
  }

  void prevDay() {
    _selectedDailyDate = _selectedDailyDate.subtract(const Duration(days: 1));
    fetchDailyReport(_selectedDailyDate);
  }

  Future<void> fetchCategoryReport({String? range, String? scope, String? from, String? to}) async {
    if (range != null) _selectedCategoryRange = range;
    if (scope != null) _selectedCategoryScope = scope;

    _isCategoryLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'range': _selectedCategoryRange,
        'scope': _selectedCategoryScope,
      };
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final res = await apiClient.get('/reports/categories', queryParams: queryParams);
      if (res['success'] == true && res['data'] != null) {
        _categoryReport = CategoryReport.fromJson(res['data']);
      }
    } catch (e) {
      debugPrint('[ReportProvider fetchCategoryReport Error] $e');
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyOverview([int? year, int? month]) async {
    if (year != null) _selectedYear = year;
    if (month != null) _selectedMonth = month;

    _isMonthlyLoading = true;
    notifyListeners();

    try {
      final queryParams = {
        'year': _selectedYear.toString(),
        'month': _selectedMonth.toString(),
      };

      final res = await apiClient.get('/reports/monthly', queryParams: queryParams);
      if (res['success'] == true && res['data'] != null) {
        _monthlyOverview = MonthlyOverview.fromJson(res['data']);
      }
    } catch (e) {
      debugPrint('[ReportProvider fetchMonthlyOverview Error] $e');
    } finally {
      _isMonthlyLoading = false;
      notifyListeners();
    }
  }

  void calculateFromTransactions(List<TransactionModel> txList) {
    // 1. Dashboard Summary
    double totalIncome = 0;
    double totalExpenses = 0;
    double totalSavings = 0;
    double personalExpenses = 0;
    double familyExpenses = 0;
    double todaySpending = 0;
    final todayExpenses = <TransactionModel>[];

    final now = DateTime.now();

    for (final tx in txList) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else if (tx.isExpense) {
        totalExpenses += tx.amount;
        if (tx.scope == 'personal') {
          personalExpenses += tx.amount;
        } else if (tx.scope == 'family') {
          familyExpenses += tx.amount;
        }
        if (DateFormatter.isSameDay(tx.date, now)) {
          todaySpending += tx.amount;
          todayExpenses.add(tx);
        }
      } else if (tx.isSavings) {
        totalSavings += tx.amount;
      }
    }

    final availableBalance = totalIncome - totalExpenses - totalSavings;
    final recent = txList.take(5).toList();

    _summary = DashboardSummary(
      availableBalance: availableBalance,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalSavings: totalSavings,
      personalExpenses: personalExpenses,
      familyExpenses: familyExpenses,
      todaySpending: todaySpending,
      todayExpenses: todayExpenses,
      recentTransactions: recent,
    );

    // 2. Daily Report for _selectedDailyDate
    double dayIncome = 0;
    double dayExpenses = 0;
    double daySavings = 0;
    double dayPersonal = 0;
    double dayFamily = 0;
    final dayTx = <TransactionModel>[];
    final Map<String, CategorySpendItem> catMap = {};

    for (final tx in txList) {
      if (DateFormatter.isSameDay(tx.date, _selectedDailyDate)) {
        dayTx.add(tx);
        if (tx.isIncome) {
          dayIncome += tx.amount;
        } else if (tx.isExpense) {
          dayExpenses += tx.amount;
          if (tx.scope == 'personal') dayPersonal += tx.amount;
          if (tx.scope == 'family') dayFamily += tx.amount;

          final cat = tx.category ?? 'Other';
          if (!catMap.containsKey(cat)) {
            catMap[cat] = CategorySpendItem(
              category: cat,
              total: 0,
              count: 0,
              personal: 0,
              family: 0,
            );
          }
          final cur = catMap[cat]!;
          catMap[cat] = CategorySpendItem(
            category: cat,
            total: cur.total + tx.amount,
            count: cur.count + 1,
            personal: cur.personal + (tx.scope == 'personal' ? tx.amount : 0),
            family: cur.family + (tx.scope == 'family' ? tx.amount : 0),
          );
        } else if (tx.isSavings) {
          daySavings += tx.amount;
        }
      }
    }

    _dailyReport = DailyReport(
      date: DateFormatter.toIsoDate(_selectedDailyDate),
      dayIncome: dayIncome,
      dayExpenses: dayExpenses,
      daySavings: daySavings,
      dayBalance: dayIncome - dayExpenses - daySavings,
      personalExpenses: dayPersonal,
      familyExpenses: dayFamily,
      categories: catMap.values.toList()..sort((a, b) => b.total.compareTo(a.total)),
      transactions: dayTx,
    );

    // 3. Category Report
    final Map<String, CategoryShareItem> catShareMap = {};
    double catRangeTotal = 0;
    for (final tx in txList) {
      if (tx.isExpense) {
        if (_selectedCategoryScope != 'all' && tx.scope != _selectedCategoryScope) {
          continue;
        }
        catRangeTotal += tx.amount;
        final cat = tx.category ?? 'Other';
        if (!catShareMap.containsKey(cat)) {
          catShareMap[cat] = CategoryShareItem(category: cat, total: 0, count: 0, percentage: 0);
        }
        final cur = catShareMap[cat]!;
        catShareMap[cat] = CategoryShareItem(
          category: cat,
          total: cur.total + tx.amount,
          count: cur.count + 1,
          percentage: 0,
        );
      }
    }

    final catShares = catShareMap.values.map((item) {
      final pct = catRangeTotal > 0 ? (item.total / catRangeTotal) * 100 : 0.0;
      return CategoryShareItem(
        category: item.category,
        total: item.total,
        count: item.count,
        percentage: double.parse(pct.toStringAsFixed(1)),
      );
    }).toList()..sort((a, b) => b.total.compareTo(a.total));

    _categoryReport = CategoryReport(
      range: _selectedCategoryRange,
      scope: _selectedCategoryScope,
      totalSpending: catRangeTotal,
      categories: catShares,
    );

    // 4. Monthly Overview
    double mIncome = 0;
    double mExpenses = 0;
    double mSavings = 0;
    double mPersonal = 0;
    double mFamily = 0;
    final Map<String, CategoryShareItem> mCatMap = {};

    for (final tx in txList) {
      if (tx.date.year == _selectedYear && tx.date.month == _selectedMonth) {
        if (tx.isIncome) {
          mIncome += tx.amount;
        } else if (tx.isExpense) {
          mExpenses += tx.amount;
          if (tx.scope == 'personal') mPersonal += tx.amount;
          if (tx.scope == 'family') mFamily += tx.amount;

          final cat = tx.category ?? 'Other';
          if (!mCatMap.containsKey(cat)) {
            mCatMap[cat] = CategoryShareItem(category: cat, total: 0, count: 0, percentage: 0);
          }
          final cur = mCatMap[cat]!;
          mCatMap[cat] = CategoryShareItem(
            category: cat,
            total: cur.total + tx.amount,
            count: cur.count + 1,
            percentage: 0,
          );
        } else if (tx.isSavings) {
          mSavings += tx.amount;
        }
      }
    }

    final mCatList = mCatMap.values.map((item) {
      final pct = mExpenses > 0 ? (item.total / mExpenses) * 100 : 0.0;
      return CategoryShareItem(
        category: item.category,
        total: item.total,
        count: item.count,
        percentage: double.parse(pct.toStringAsFixed(1)),
      );
    }).toList()..sort((a, b) => b.total.compareTo(a.total));

    _monthlyOverview = MonthlyOverview(
      year: _selectedYear,
      month: _selectedMonth,
      totalIncome: mIncome,
      totalExpenses: mExpenses,
      personalExpenses: mPersonal,
      familyExpenses: mFamily,
      totalSavings: mSavings,
      availableBalance: mIncome - mExpenses - mSavings,
      categories: mCatList,
    );

    notifyListeners();
  }

  void nextMonth() {
    if (_selectedMonth == 12) {
      _selectedMonth = 1;
      _selectedYear++;
    } else {
      _selectedMonth++;
    }
    fetchMonthlyOverview(_selectedYear, _selectedMonth);
  }

  void prevMonth() {
    if (_selectedMonth == 1) {
      _selectedMonth = 12;
      _selectedYear--;
    } else {
      _selectedMonth--;
    }
    fetchMonthlyOverview(_selectedYear, _selectedMonth);
  }
}
