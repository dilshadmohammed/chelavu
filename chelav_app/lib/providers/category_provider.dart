import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CategoryModel> get personalCategories =>
      _categories.where((c) => c.scope == 'personal' && !c.isDisabled).toList();

  List<CategoryModel> get familyCategories =>
      _categories.where((c) => c.scope == 'family' && !c.isDisabled).toList();

  List<CategoryModel> get allActiveCategories =>
      _categories.where((c) => !c.isDisabled).toList();

  CategoryProvider({required this.apiClient});

  Future<void> fetchCategories({bool includeDisabled = true}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await apiClient.get('/categories', queryParams: {
        'includeDisabled': includeDisabled.toString(),
      });

      if (res['success'] == true && res['categories'] != null) {
        _categories = (res['categories'] as List)
            .map((c) => CategoryModel.fromJson(c))
            .toList();
      }
    } catch (e) {
      debugPrint('[CategoryProvider fetch Error] $e');
      if (_categories.isEmpty) {
        _seedDefaultLocalCategories();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _seedDefaultLocalCategories() {
    _categories = [
      CategoryModel(id: 'p1', name: 'Food', scope: 'personal', icon: 'utensils', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 1),
      CategoryModel(id: 'p2', name: 'Fuel', scope: 'personal', icon: 'fuel', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 2),
      CategoryModel(id: 'p3', name: 'Travel', scope: 'personal', icon: 'car', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 3),
      CategoryModel(id: 'p4', name: 'Medical', scope: 'personal', icon: 'heart-pulse', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 4),
      CategoryModel(id: 'p5', name: 'Shopping', scope: 'personal', icon: 'shopping-bag', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 5),
      CategoryModel(id: 'p6', name: 'Bills', scope: 'personal', icon: 'receipt', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 6),
      CategoryModel(id: 'p7', name: 'Entertainment', scope: 'personal', icon: 'film', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 7),
      CategoryModel(id: 'p8', name: 'Education', scope: 'personal', icon: 'graduation-cap', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 8),
      CategoryModel(id: 'p9', name: 'Household', scope: 'personal', icon: 'home', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 9),
      CategoryModel(id: 'p10', name: 'Other', scope: 'personal', icon: 'circle-dot', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 10),
      CategoryModel(id: 'f1', name: 'Food', scope: 'family', icon: 'utensils', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 1),
      CategoryModel(id: 'f2', name: 'Household', scope: 'family', icon: 'home', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 2),
      CategoryModel(id: 'f3', name: 'Medical', scope: 'family', icon: 'heart-pulse', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 3),
      CategoryModel(id: 'f4', name: 'Education', scope: 'family', icon: 'graduation-cap', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 4),
      CategoryModel(id: 'f5', name: 'Bills', scope: 'family', icon: 'receipt', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 5),
      CategoryModel(id: 'f6', name: 'Other', scope: 'family', icon: 'circle-dot', color: '#71717A', isCustom: false, isDisabled: false, sortOrder: 6),
    ];
  }

  Future<bool> createCategory({
    required String name,
    required String scope,
    String? icon,
    String? color,
  }) async {
    try {
      final res = await apiClient.post('/categories', {
        'name': name.trim(),
        'scope': scope,
        'icon': icon ?? 'tag',
        'color': color ?? '#71717A',
      });

      if (res['success'] == true && res['category'] != null) {
        final newCat = CategoryModel.fromJson(res['category']);
        _categories.add(newCat);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[CategoryProvider create Error] $e');
      // Local fallback
      final newCat = CategoryModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        scope: scope,
        icon: icon ?? 'tag',
        color: color ?? '#71717A',
        isCustom: true,
        isDisabled: false,
        sortOrder: _categories.length + 1,
      );
      _categories.add(newCat);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateCategory({
    required String id,
    String? name,
    bool? isDisabled,
    String? icon,
    String? color,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (isDisabled != null) body['isDisabled'] = isDisabled;
      if (icon != null) body['icon'] = icon;
      if (color != null) body['color'] = color;

      final res = await apiClient.put('/categories/$id', body);
      if (res['success'] == true && res['category'] != null) {
        final updated = CategoryModel.fromJson(res['category']);
        final index = _categories.indexWhere((c) => c.id == id);
        if (index != -1) {
          _categories[index] = updated;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('[CategoryProvider update Error] $e');
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = _categories[index].copyWith(
          name: name,
          isDisabled: isDisabled,
          icon: icon,
          color: color,
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final res = await apiClient.delete('/categories/$id');
      if (res['success'] == true) {
        _categories.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[CategoryProvider delete Error] $e');
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}
