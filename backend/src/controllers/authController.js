const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Category = require('../models/Category');

const generateToken = (id) => {
  const secret = process.env.JWT_SECRET || 'chelav_super_secret_jwt_key_2026_finance';
  const expiresIn = process.env.JWT_EXPIRES_IN || '30d';
  return jwt.sign({ id }, secret, { expiresIn });
};

const DEFAULT_PERSONAL_CATEGORIES = [
  { name: 'Food', icon: 'utensils', color: '#71717A', sortOrder: 1 },
  { name: 'Fuel', icon: 'fuel', color: '#71717A', sortOrder: 2 },
  { name: 'Travel', icon: 'car', color: '#71717A', sortOrder: 3 },
  { name: 'Medical', icon: 'heart-pulse', color: '#71717A', sortOrder: 4 },
  { name: 'Shopping', icon: 'shopping-bag', color: '#71717A', sortOrder: 5 },
  { name: 'Bills', icon: 'receipt', color: '#71717A', sortOrder: 6 },
  { name: 'Entertainment', icon: 'film', color: '#71717A', sortOrder: 7 },
  { name: 'Education', icon: 'graduation-cap', color: '#71717A', sortOrder: 8 },
  { name: 'Household', icon: 'home', color: '#71717A', sortOrder: 9 },
  { name: 'Other', icon: 'circle-dot', color: '#71717A', sortOrder: 10 },
];

const DEFAULT_FAMILY_CATEGORIES = [
  { name: 'Food', icon: 'utensils', color: '#71717A', sortOrder: 1 },
  { name: 'Household', icon: 'home', color: '#71717A', sortOrder: 2 },
  { name: 'Medical', icon: 'heart-pulse', color: '#71717A', sortOrder: 3 },
  { name: 'Education', icon: 'graduation-cap', color: '#71717A', sortOrder: 4 },
  { name: 'Bills', icon: 'receipt', color: '#71717A', sortOrder: 5 },
  { name: 'Other', icon: 'circle-dot', color: '#71717A', sortOrder: 6 },
];

async function seedUserCategories(userId) {
  const categoriesToInsert = [];

  for (const cat of DEFAULT_PERSONAL_CATEGORIES) {
    categoriesToInsert.push({
      userId,
      name: cat.name,
      scope: 'personal',
      icon: cat.icon,
      color: cat.color,
      isCustom: false,
      isDisabled: false,
      sortOrder: cat.sortOrder,
    });
  }

  for (const cat of DEFAULT_FAMILY_CATEGORIES) {
    categoriesToInsert.push({
      userId,
      name: cat.name,
      scope: 'family',
      icon: cat.icon,
      color: cat.color,
      isCustom: false,
      isDisabled: false,
      sortOrder: cat.sortOrder,
    });
  }

  await Category.insertMany(categoriesToInsert);
}

// @desc    Register a new user
// @route   POST /api/auth/register
const register = async (req, res) => {
  try {
    const { name, email, password, currency } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide name, email, and password',
      });
    }

    const userExists = await User.findOne({ email: email.toLowerCase() });
    if (userExists) {
      return res.status(400).json({
        success: false,
        message: 'A user with this email already exists',
      });
    }

    const user = await User.create({
      name,
      email: email.toLowerCase(),
      password,
      currency: currency || 'INR',
    });

    // Seed default categories
    await seedUserCategories(user._id);

    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        currency: user.currency,
      },
    });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Server error during registration',
    });
  }
};

// @desc    Authenticate user & get token
// @route   POST /api/auth/login
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password',
      });
    }

    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // Check if user has categories seeded (in case of legacy account)
    const catCount = await Category.countDocuments({ userId: user._id });
    if (catCount === 0) {
      await seedUserCategories(user._id);
    }

    const token = generateToken(user._id);

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        currency: user.currency,
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Server error during login',
    });
  }
};

// @desc    Get current user profile
// @route   GET /api/auth/me
const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.json({
      success: true,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        currency: user.currency,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message || 'Server error fetching user profile',
    });
  }
};

module.exports = {
  register,
  login,
  getMe,
  seedUserCategories,
};
