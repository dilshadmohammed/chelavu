class CategoryModel {
  final String id;
  final String name;
  final String scope; // 'personal' or 'family'
  final String icon;
  final String color;
  final bool isCustom;
  final bool isDisabled;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.scope,
    required this.icon,
    required this.color,
    required this.isCustom,
    required this.isDisabled,
    required this.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      scope: json['scope'] ?? 'personal',
      icon: json['icon'] ?? 'tag',
      color: json['color'] ?? '#71717A',
      isCustom: json['isCustom'] ?? false,
      isDisabled: json['isDisabled'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scope': scope,
      'icon': icon,
      'color': color,
      'isCustom': isCustom,
      'isDisabled': isDisabled,
      'sortOrder': sortOrder,
    };
  }

  CategoryModel copyWith({
    String? name,
    String? scope,
    String? icon,
    String? color,
    bool? isCustom,
    bool? isDisabled,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      scope: scope ?? this.scope,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
      isDisabled: isDisabled ?? this.isDisabled,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
