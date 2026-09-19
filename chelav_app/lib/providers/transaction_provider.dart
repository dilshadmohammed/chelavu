import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/transaction_model.dart';
import 'report_provider.dart';

class TransactionProvider extends ChangeNotifier {
  final ApiClient apiClient;
  ReportProvider? reportProvider;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedType = 'all'; // 'all', 'expense', 'income', 'savings'
  String _selectedScope = 'all'; // 'all', 'personal', 'family'
  String? _selectedCategory;

  List<TransactionModel> get transactions => _filteredTransactions();
  List<TransactionModel> get rawTransactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String get selectedScope => _selectedScope;
  String? get selectedCategory => _selectedCategory;

  TransactionProvider({required this.apiClient});

  void updateReportProvider(ReportProvider reportProv) {
    reportProvider = reportProv;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTypeFilter(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setScopeFilter(String scope) {
    _selectedScope = scope;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = 'all';
    _selectedScope = 'all';
    _selectedCategory = null;
    notifyListeners();
  }

  List<TransactionModel> _filteredTransactions() {
    return _transactions.where((t) {
      // Type filter
      if (_selectedType != 'all' && t.type != _selectedType) return false;

      // Scope filter (only applies to expenses)
      if (_selectedScope != 'all') {
        if (t.type != 'expense' || t.scope != _selectedScope) return false;
      }

      // Category filter
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        if (t.category != _selectedCategory) return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchDesc = t.description.toLowerCase().contains(query);
        final matchCat = t.category?.toLowerCase().contains(query) ?? false;
        final matchSrc = t.source?.toLowerCase().contains(query) ?? false;
        final matchDest = t.destination?.toLowerCase().contains(query) ?? false;
        if (!matchDesc && !matchCat && !matchSrc && !matchDest) return false;
      }

      return true;
    }).toList();
  }

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get('/transactions', queryParams: {
        'limit': '100',
      });

      if (res['success'] == true && res['transactions'] != null) {
        _transactions = (res['transactions'] as List)
            .map((t) => TransactionModel.fromJson(t))
            .toList();
      }
    } catch (e) {
      debugPrint('[TransactionProvider fetch Error] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createExpense({
    required double amount,
    required String scope,
    required String category,
    DateTime? date,
    String? description,
  }) async {
    return _createTransaction({
      'type': 'expense',
      'amount': amount,
      'scope': scope,
      'category': category,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'description': description ?? '',
    });
  }

  Future<bool> createIncome({
    required double amount,
    required String source,
    DateTime? date,
    String? description,
  }) async {
    return _createTransaction({
      'type': 'income',
      'amount': amount,
      'source': source,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'description': description ?? '',
    });
  }

  Future<bool> createSavings({
    required double amount,
    required String destination,
    DateTime? date,
    String? description,
  }) async {
    return _createTransaction({
      'type': 'savings',
      'amount': amount,
      'destination': destination,
      'date': (date ?? DateTime.now()).toIso8601String(),
      'description': description ?? '',
    });
  }

  Future<bool> _createTransaction(Map<String, dynamic> body) async {
    try {
      final res = await apiClient.post('/transactions', body);
      if (res['success'] == true && res['transaction'] != null) {
        final newTx = TransactionModel.fromJson(res['transaction']);
        _transactions.insert(0, newTx);
        notifyListeners();
        _refreshReports();
        return true;
      }
    } catch (e) {
      debugPrint('[TransactionProvider create Error] $e');
      // Local fallback
      final newTx = TransactionModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        type: body['type'],
        amount: (body['amount'] as num).toDouble(),
        date: DateTime.parse(body['date']),
        scope: body['scope'],
        category: body['category'],
        source: body['source'],
        destination: body['destination'],
        description: body['description'] ?? '',
      );
      _transactions.insert(0, newTx);
      notifyListeners();
      _refreshReports();
      return true;
    }
    return false;
  }

  Future<bool> updateTransaction(String id, Map<String, dynamic> updates) async {
    try {
      final res = await apiClient.put('/transactions/$id', updates);
      if (res['success'] == true && res['transaction'] != null) {
        final updatedTx = TransactionModel.fromJson(res['transaction']);
        final idx = _transactions.indexWhere((t) => t.id == id);
        if (idx != -1) {
          _transactions[idx] = updatedTx;
          notifyListeners();
          _refreshReports();
        }
        return true;
      }
    } catch (e) {
      debugPrint('[TransactionProvider update Error] $e');
    }
    return false;
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      final res = await apiClient.delete('/transactions/$id');
      if (res['success'] == true) {
        _transactions.removeWhere((t) => t.id == id);
        notifyListeners();
        _refreshReports();
        return true;
      }
    } catch (e) {
      debugPrint('[TransactionProvider delete Error] $e');
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      _refreshReports();
      return true;
    }
    return false;
  }

  void _refreshReports() {
    reportProvider?.calculateFromTransactions(_transactions);
    reportProvider?.fetchSummary();
    reportProvider?.fetchDailyReport();
    reportProvider?.fetchCategoryReport();
    reportProvider?.fetchMonthlyOverview();
  }
}
