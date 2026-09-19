const Transaction = require('../models/Transaction');

// @desc    Get all transactions with rich filtering & search
// @route   GET /api/transactions
const getTransactions = async (req, res) => {
  try {
    const {
      type,
      scope,
      category,
      search,
      startDate,
      endDate,
      page = 1,
      limit = 50,
      sort = '-date',
    } = req.query;

    const filter = { userId: req.user._id };

    if (type && ['expense', 'income', 'savings'].includes(type)) {
      filter.type = type;
    }

    if (scope && ['personal', 'family'].includes(scope)) {
      filter.scope = scope;
    }

    if (category) {
      filter.category = category;
    }

    if (startDate || endDate) {
      filter.date = {};
      if (startDate) {
        filter.date.$gte = new Date(startDate);
      }
      if (endDate) {
        // Include full day
        const end = new Date(endDate);
        if (endDate.length === 10) {
          end.setHours(23, 59, 59, 999);
        }
        filter.date.$lte = end;
      }
    }

    if (search) {
      const regex = new RegExp(search.trim(), 'i');
      filter.$or = [
        { description: regex },
        { category: regex },
        { source: regex },
        { destination: regex },
      ];
    }

    const skip = (parseInt(page, 10) - 1) * parseInt(limit, 10);
    const take = parseInt(limit, 10);

    const [transactions, total] = await Promise.all([
      Transaction.find(filter).sort(sort).skip(skip).limit(take),
      Transaction.countDocuments(filter),
    ]);

    res.json({
      success: true,
      count: transactions.length,
      total,
      page: parseInt(page, 10),
      pages: Math.ceil(total / take) || 1,
      transactions,
    });
  } catch (err) {
    console.error('getTransactions error:', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Server error fetching transactions',
    });
  }
};

// @desc    Get single transaction by ID
// @route   GET /api/transactions/:id
const getTransactionById = async (req, res) => {
  try {
    const transaction = await Transaction.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found',
      });
    }

    res.json({
      success: true,
      transaction,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message || 'Server error fetching transaction',
    });
  }
};

// @desc    Create a new transaction (Expense, Income, or Savings)
// @route   POST /api/transactions
const createTransaction = async (req, res) => {
  try {
    const {
      type,
      amount,
      date,
      scope,
      category,
      source,
      destination,
      description,
    } = req.body;

    if (!type || !['expense', 'income', 'savings'].includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or missing transaction type (expense, income, savings)',
      });
    }

    const parsedAmount = parseFloat(amount);
    if (isNaN(parsedAmount) || parsedAmount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be a positive number',
      });
    }

    const transactionData = {
      userId: req.user._id,
      type,
      amount: parsedAmount,
      date: date ? new Date(date) : new Date(),
      description: description ? description.trim() : '',
    };

    if (type === 'expense') {
      if (!scope || !['personal', 'family'].includes(scope)) {
        return res.status(400).json({
          success: false,
          message: 'Expenses require scope (personal or family)',
        });
      }
      if (!category || !category.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Expenses require a category',
        });
      }
      transactionData.scope = scope;
      transactionData.category = category.trim();
    } else if (type === 'income') {
      if (!source || !source.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Income requires a source (e.g. Salary, Freelance, Bonus)',
        });
      }
      transactionData.source = source.trim();
    } else if (type === 'savings') {
      if (!destination || !destination.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Savings requires a destination/description',
        });
      }
      transactionData.destination = destination.trim();
    }

    const transaction = await Transaction.create(transactionData);

    res.status(201).json({
      success: true,
      transaction,
    });
  } catch (err) {
    console.error('createTransaction error:', err);
    res.status(500).json({
      success: false,
      message: err.message || 'Server error creating transaction',
    });
  }
};

// @desc    Update an existing transaction
// @route   PUT /api/transactions/:id
const updateTransaction = async (req, res) => {
  try {
    const transaction = await Transaction.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found',
      });
    }

    const {
      amount,
      date,
      scope,
      category,
      source,
      destination,
      description,
    } = req.body;

    if (amount !== undefined) {
      const parsedAmount = parseFloat(amount);
      if (isNaN(parsedAmount) || parsedAmount <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Amount must be a positive number',
        });
      }
      transaction.amount = parsedAmount;
    }

    if (date !== undefined) transaction.date = new Date(date);
    if (description !== undefined) transaction.description = description.trim();

    if (transaction.type === 'expense') {
      if (scope !== undefined) {
        if (!['personal', 'family'].includes(scope)) {
          return res.status(400).json({
            success: false,
            message: 'Scope must be personal or family',
          });
        }
        transaction.scope = scope;
      }
      if (category !== undefined) transaction.category = category.trim();
    } else if (transaction.type === 'income') {
      if (source !== undefined) transaction.source = source.trim();
    } else if (transaction.type === 'savings') {
      if (destination !== undefined) transaction.destination = destination.trim();
    }

    await transaction.save();

    res.json({
      success: true,
      transaction,
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message || 'Server error updating transaction',
    });
  }
};

// @desc    Delete transaction
// @route   DELETE /api/transactions/:id
const deleteTransaction = async (req, res) => {
  try {
    const transaction = await Transaction.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        message: 'Transaction not found',
      });
    }

    await transaction.deleteOne();

    res.json({
      success: true,
      message: 'Transaction deleted successfully',
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: err.message || 'Server error deleting transaction',
    });
  }
};

module.exports = {
  getTransactions,
  getTransactionById,
  createTransaction,
  updateTransaction,
  deleteTransaction,
};
