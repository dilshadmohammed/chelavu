class TransactionModel {
  final String id;
  final String type; // 'expense', 'income', 'savings'
  final double amount;
  final DateTime date;
  final String? scope; // 'personal' or 'family'
  final String? category; // For expense
  final String? source; // For income
  final String? destination; // For savings
  final String description;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.scope,
    this.category,
    this.source,
    this.destination,
    this.description = '',
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
  bool get isSavings => type == 'savings';
  bool get isPersonal => scope == 'personal';
  bool get isFamily => scope == 'family';

  String get title {
    if (isExpense) return category ?? 'Expense';
    if (isIncome) return source ?? 'Income';
    if (isSavings) return destination ?? 'Savings';
    return 'Transaction';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? json['_id'] ?? '',
      type: json['type'] ?? 'expense',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']).toLocal() : DateTime.now(),
      scope: json['scope'],
      category: json['category'],
      source: json['source'],
      destination: json['destination'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      if (scope != null) 'scope': scope,
      if (category != null) 'category': category,
      if (source != null) 'source': source,
      if (destination != null) 'destination': destination,
      'description': description,
    };
  }
}
