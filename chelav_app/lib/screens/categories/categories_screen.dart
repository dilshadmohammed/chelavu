import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(String scope) {
    final nameController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${scope.toUpperCase()} Category'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Category Name (e.g. Groceries, Pet Care)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await context.read<CategoryProvider>().createCategory(
                    name: name,
                    scope: scope,
                  );
              if (mounted && !ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to add category')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(CategoryModel cat) {
    final nameController = TextEditingController(text: cat.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rename "${cat.name}"'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'New Category Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty || newName == cat.name) return;
              Navigator.pop(ctx);
              await context.read<CategoryProvider>().updateCategory(
                    id: cat.id,
                    name: newName,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(CategoryModel cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${cat.name}"?'),
        content: const Text(
          'Existing transactions with this category will keep their label, but this category will no longer appear in new expense lists.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<CategoryProvider>().deleteCategory(cat.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.semanticRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catProv = context.watch<CategoryProvider>();

    final personalCats = catProv.categories.where((c) => c.scope == 'personal').toList();
    final familyCats = catProv.categories.where((c) => c.scope == 'family').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? Colors.white : Colors.black,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          tabs: [
            Tab(text: 'Personal (${personalCats.length})'),
            Tab(text: 'Family (${familyCats.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(personalCats, 'personal', isDark),
          _buildCategoryList(familyCats, 'family', isDark),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<CategoryModel> list, String scope, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Add Category Button
        OutlinedButton.icon(
          onPressed: () => _showAddCategoryDialog(scope),
          icon: const Icon(Icons.add, size: 18),
          label: Text('New ${scope == 'personal' ? 'Personal' : 'Family'} Category'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            foregroundColor: isDark ? Colors.white : Colors.black,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 14),

        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            alignment: Alignment.center,
            child: Text(
              'No categories configured.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          )
        else
          ...list.map((cat) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141414) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.sell_outlined,
                      size: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              cat.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: cat.isDisabled ? TextDecoration.lineThrough : null,
                                color: cat.isDisabled
                                    ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                            ),
                            if (cat.isCustom) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF262626) : const Color(0xFFE4E4E7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Custom',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          cat.isDisabled ? 'Disabled' : 'Active',
                          style: TextStyle(
                            fontSize: 11,
                            color: cat.isDisabled
                                ? AppColors.semanticRed
                                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Actions: Toggle Disable, Rename, Delete
                  IconButton(
                    icon: Icon(
                      cat.isDisabled ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    onPressed: () {
                      context.read<CategoryProvider>().updateCategory(
                            id: cat.id,
                            isDisabled: !cat.isDisabled,
                          );
                    },
                    tooltip: cat.isDisabled ? 'Enable' : 'Disable',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _showRenameDialog(cat),
                    tooltip: 'Rename',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.semanticRed),
                    onPressed: () => _confirmDelete(cat),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 30),
      ],
    );
  }
}
