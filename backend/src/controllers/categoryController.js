const Category = require('../models/Category');
const Transaction = require('../models/Transaction');

// @desc    Get all categories for user (optionally filtered by scope)
// @route   GET /api/categories
const getCategories = async (req, res) => {
  try {
    const { scope, includeDisabled } = req.query;
    const filter = { userId: req.user._id };

    if (scope && (scope === 'personal' || scope === 'family')) {
      filter.scope = scope;
    }

    if (includeDisabled !== 'true') {
      filter.isDisabled = false;
    }

    const categories = await Category.find(filter).sort({ sortOrder: 1, name: 1 });

    res.json({
      success: true,
      count: categories.length,
      categories,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message || 'Server error fetching categories',
    });
  }
};

// @desc    Create a new custom category
// @route   POST /api/categories
const createCategory = async (req, res) => {
  try {
    const { name, scope, icon, color } = req.body;

    if (!name || !scope) {
      return res.status(400).json({
        success: false,
        message: 'Name and scope (personal or family) are required',
      });
    }

    if (!['personal', 'family'].includes(scope)) {
      return res.status(400).json({
        success: false,
        message: 'Scope must be either personal or family',
      });
    }

    const existing = await Category.findOne({
      userId: req.user._id,
      scope,
      name: { $regex: new RegExp(`^${name.trim()}$`, 'i') },
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: `A ${scope} category with name "${name.trim()}" already exists`,
      });
    }

    const maxSort = await Category.findOne({ userId: req.user._id, scope })
      .sort({ sortOrder: -1 })
      .select('sortOrder');

    const sortOrder = maxSort && maxSort.sortOrder ? maxSort.sortOrder + 1 : 1;

    const category = await Category.create({
      userId: req.user._id,
      name: name.trim(),
      scope,
      icon: icon || 'tag',
      color: color || '#71717A',
      isCustom: true,
      isDisabled: false,
      sortOrder,
    });

    res.status(201).json({
      success: true,
      category,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message || 'Server error creating category',
    });
  }
};

// @desc    Update category (rename, disable/enable, change icon)
// @route   PUT /api/categories/:id
const updateCategory = async (req, res) => {
  try {
    const { name, icon, color, isDisabled, sortOrder } = req.body;
    const category = await Category.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Category not found',
      });
    }

    const oldName = category.name;

    if (name && name.trim() !== category.name) {
      // Check duplicate name in same scope
      const existing = await Category.findOne({
        userId: req.user._id,
        scope: category.scope,
        _id: { $ne: category._id },
        name: { $regex: new RegExp(`^${name.trim()}$`, 'i') },
      });

      if (existing) {
        return res.status(400).json({
          success: false,
          message: `A ${category.scope} category named "${name.trim()}" already exists`,
        });
      }

      category.name = name.trim();

      // Also update existing transactions referencing this category name
      await Transaction.updateMany(
        { userId: req.user._id, scope: category.scope, category: oldName },
        { $set: { category: name.trim() } }
      );
    }

    if (icon !== undefined) category.icon = icon;
    if (color !== undefined) category.color = color;
    if (isDisabled !== undefined) category.isDisabled = isDisabled;
    if (sortOrder !== undefined) category.sortOrder = sortOrder;

    await category.save();

    res.json({
      success: true,
      category,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message || 'Server error updating category',
    });
  }
};

// @desc    Delete category
// @route   DELETE /api/categories/:id
const deleteCategory = async (req, res) => {
  try {
    const category = await Category.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Category not found',
      });
    }

    await category.deleteOne();

    res.json({
      success: true,
      message: 'Category deleted successfully',
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message || 'Server error deleting category',
    });
  }
};

module.exports = {
  getCategories,
  createCategory,
  updateCategory,
  deleteCategory,
};
