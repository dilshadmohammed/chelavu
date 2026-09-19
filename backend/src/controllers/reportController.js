const Transaction = require('../models/Transaction');

// Helper to calculate Indian Rupee date boundaries (or local user timezone)
function getDayRange(dateStr) {
  const d = dateStr ? new Date(dateStr) : new Date();
  const start = new Date(d);
  start.setHours(0, 0, 0, 0);
  const end = new Date(d);
  end.setHours(23, 59, 59, 999);
  return { start, end };
}

// @desc    Dashboard summary (all-time totals + today's snapshot + recent expenses)
// @route   GET /api/reports/summary
const getDashboardSummary = async (req, res) => {
  try {
    const userId = req.user._id;

    // All-time aggregation
    const totalsAgg = await Transaction.aggregate([
      { $match: { userId } },
      {
        $group: {
          _id: '$type',
          total: { $sum: '$amount' },
        },
      },
    ]);

    let totalIncome = 0;
    let totalExpenses = 0;
    let totalSavings = 0;

    totalsAgg.forEach((item) => {
      if (item._id === 'income') totalIncome = item.total;
      if (item._id === 'expense') totalExpenses = item.total;
      if (item._id === 'savings') totalSavings = item.total;
    });

    // Available balance = Income - Expenses - Savings
    const availableBalance = totalIncome - totalExpenses - totalSavings;

    // Expense breakdown by scope (Personal vs Family)
    const scopeAgg = await Transaction.aggregate([
      { $match: { userId, type: 'expense' } },
      {
        $group: {
          _id: '$scope',
          total: { $sum: '$amount' },
        },
      },
    ]);

    let personalExpenses = 0;
    let familyExpenses = 0;

    scopeAgg.forEach((item) => {
      if (item._id === 'personal') personalExpenses = item.total;
      if (item._id === 'family') familyExpenses = item.total;
    });

    // Today's range
    const today = new Date();
    const todayStart = new Date(today);
    todayStart.setHours(0, 0, 0, 0);
    const todayEnd = new Date(today);
    todayEnd.setHours(23, 59, 59, 999);

    // Today's spending
    const todaySpendAgg = await Transaction.aggregate([
      {
        $match: {
          userId,
          type: 'expense',
          date: { $gte: todayStart, $lte: todayEnd },
        },
      },
      {
        $group: {
          _id: null,
          total: { $sum: '$amount' },
        },
      },
    ]);

    const todaySpending = todaySpendAgg.length > 0 ? todaySpendAgg[0].total : 0;

    // Today's expenses list
    const todayExpenses = await Transaction.find({
      userId,
      type: 'expense',
      date: { $gte: todayStart, $lte: todayEnd },
    }).sort({ date: -1 });

    // Recent 5 transactions across all types
    const recentTransactions = await Transaction.find({ userId })
      .sort({ date: -1 })
      .limit(5);

    res.json({
      success: true,
      data: {
        availableBalance,
        totalIncome,
        totalExpenses,
        totalSavings,
        personalExpenses,
        familyExpenses,
        todaySpending,
        todayExpenses,
        recentTransactions,
      },
    });
  } catch (err) {
    console.error('getDashboardSummary error:', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Server error fetching dashboard summary',
    });
  }
};

// @desc    Daily report for a specific day
// @route   GET /api/reports/daily?date=YYYY-MM-DD
const getDailyReport = async (req, res) => {
  try {
    const userId = req.user._id;
    const { date } = req.query;

    const targetDate = date ? new Date(date) : new Date();
    const start = new Date(targetDate);
    start.setHours(0, 0, 0, 0);
    const end = new Date(targetDate);
    end.setHours(23, 59, 59, 999);

    // Day totals by type
    const dayTotalsAgg = await Transaction.aggregate([
      {
        $match: {
          userId,
          date: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: '$type',
          total: { $sum: '$amount' },
        },
      },
    ]);

    let dayIncome = 0;
    let dayExpenses = 0;
    let daySavings = 0;

    dayTotalsAgg.forEach((item) => {
      if (item._id === 'income') dayIncome = item.total;
      if (item._id === 'expense') dayExpenses = item.total;
      if (item._id === 'savings') daySavings = item.total;
    });

    const dayBalance = dayIncome - dayExpenses - daySavings;

    // Category breakdown for this day
    const categoryAgg = await Transaction.aggregate([
      {
        $match: {
          userId,
          type: 'expense',
          date: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: { category: '$category', scope: '$scope' },
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { total: -1 } },
    ]);

    let personalExpenses = 0;
    let familyExpenses = 0;

    const categoryMap = {};
    categoryAgg.forEach((item) => {
      const cat = item._id.category;
      const scope = item._id.scope;
      if (scope === 'personal') personalExpenses += item.total;
      if (scope === 'family') familyExpenses += item.total;

      if (!categoryMap[cat]) {
        categoryMap[cat] = { category: cat, total: 0, count: 0, personal: 0, family: 0 };
      }
      categoryMap[cat].total += item.total;
      categoryMap[cat].count += item.count;
      if (scope === 'personal') categoryMap[cat].personal += item.total;
      if (scope === 'family') categoryMap[cat].family += item.total;
    });

    const categories = Object.values(categoryMap).sort((a, b) => b.total - a.total);

    // All transactions for this day
    const transactions = await Transaction.find({
      userId,
      date: { $gte: start, $lte: end },
    }).sort({ date: -1 });

    res.json({
      success: true,
      data: {
        date: start.toISOString().split('T')[0],
        dayIncome,
        dayExpenses,
        daySavings,
        dayBalance,
        personalExpenses,
        familyExpenses,
        categories,
        transactions,
      },
    });
  } catch (err) {
    console.error('getDailyReport error:', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Server error fetching daily report',
    });
  }
};

// @desc    Category-wise spending report with flexible date range & scope filter
// @route   GET /api/reports/categories?range=today|week|month|last_month|custom&scope=all|personal|family&from=...&to=...
const getCategoryReport = async (req, res) => {
  try {
    const userId = req.user._id;
    const { range = 'month', scope = 'all', from, to } = req.query;

    const now = new Date();
    let start;
    let end = new Date();
    end.setHours(23, 59, 59, 999);

    if (range === 'today') {
      start = new Date(now);
      start.setHours(0, 0, 0, 0);
    } else if (range === 'week') {
      start = new Date(now);
      const dayOfWeek = start.getDay(); // 0 is Sunday
      const diff = start.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1); // Monday
      start.setDate(diff);
      start.setHours(0, 0, 0, 0);
    } else if (range === 'month') {
      start = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0, 0);
    } else if (range === 'last_month') {
      start = new Date(now.getFullYear(), now.getMonth() - 1, 1, 0, 0, 0, 0);
      end = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999);
    } else if (range === 'custom' && from) {
      start = new Date(from);
      start.setHours(0, 0, 0, 0);
      if (to) {
        end = new Date(to);
        end.setHours(23, 59, 59, 999);
      }
    } else {
      start = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0, 0);
    }

    const matchQuery = {
      userId,
      type: 'expense',
      date: { $gte: start, $lte: end },
    };

    if (scope && (scope === 'personal' || scope === 'family')) {
      matchQuery.scope = scope;
    }

    const categoryAgg = await Transaction.aggregate([
      { $match: matchQuery },
      {
        $group: {
          _id: '$category',
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { total: -1 } },
    ]);

    const totalSpending = categoryAgg.reduce((acc, curr) => acc + curr.total, 0);

    const categoriesWithShare = categoryAgg.map((cat) => ({
      category: cat._id,
      total: cat.total,
      count: cat.count,
      percentage: totalSpending > 0 ? Number(((cat.total / totalSpending) * 100).toFixed(1)) : 0,
    }));

    res.json({
      success: true,
      data: {
        range,
        scope,
        startDate: start.toISOString(),
        endDate: end.toISOString(),
        totalSpending,
        categories: categoriesWithShare,
      },
    });
  } catch (err) {
    console.error('getCategoryReport error:', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Server error fetching category report',
    });
  }
};

// @desc    Monthly financial summary overview
// @route   GET /api/reports/monthly?year=YYYY&month=MM (1-indexed month: 1 = Jan, 9 = Sept)
const getMonthlyOverview = async (req, res) => {
  try {
    const userId = req.user._id;
    const now = new Date();
    const year = parseInt(req.query.year, 10) || now.getFullYear();
    const month = parseInt(req.query.month, 10) || now.getMonth() + 1;

    const start = new Date(year, month - 1, 1, 0, 0, 0, 0);
    const end = new Date(year, month, 0, 23, 59, 59, 999);

    const monthlyTotalsAgg = await Transaction.aggregate([
      {
        $match: {
          userId,
          date: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: '$type',
          total: { $sum: '$amount' },
        },
      },
    ]);

    let totalIncome = 0;
    let totalExpenses = 0;
    let totalSavings = 0;

    monthlyTotalsAgg.forEach((item) => {
      if (item._id === 'income') totalIncome = item.total;
      if (item._id === 'expense') totalExpenses = item.total;
      if (item._id === 'savings') totalSavings = item.total;
    });

    const availableBalance = totalIncome - totalExpenses - totalSavings;

    // Scope breakdown
    const scopeAgg = await Transaction.aggregate([
      {
        $match: {
          userId,
          type: 'expense',
          date: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: '$scope',
          total: { $sum: '$amount' },
        },
      },
    ]);

    let personalExpenses = 0;
    let familyExpenses = 0;

    scopeAgg.forEach((item) => {
      if (item._id === 'personal') personalExpenses = item.total;
      if (item._id === 'family') familyExpenses = item.total;
    });

    // Category breakdown
    const categoryAgg = await Transaction.aggregate([
      {
        $match: {
          userId,
          type: 'expense',
          date: { $gte: start, $lte: end },
        },
      },
      {
        $group: {
          _id: '$category',
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { total: -1 } },
    ]);

    const categories = categoryAgg.map((cat) => ({
      category: cat._id,
      total: cat.total,
      count: cat.count,
      percentage: totalExpenses > 0 ? Number(((cat.total / totalExpenses) * 100).toFixed(1)) : 0,
    }));

    res.json({
      success: true,
      data: {
        year,
        month,
        startDate: start.toISOString(),
        endDate: end.toISOString(),
        totalIncome,
        totalExpenses,
        personalExpenses,
        familyExpenses,
        totalSavings,
        availableBalance,
        categories,
      },
    });
  } catch (err) {
    console.error('getMonthlyOverview error:', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Server error fetching monthly overview',
    });
  }
};

module.exports = {
  getDashboardSummary,
  getDailyReport,
  getCategoryReport,
  getMonthlyOverview,
};
