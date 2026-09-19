const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: ['expense', 'income', 'savings'],
      required: [true, 'Transaction type is required'],
      index: true,
    },
    amount: {
      type: Number,
      required: [true, 'Amount is required'],
      min: [0.01, 'Amount must be greater than zero'],
    },
    date: {
      type: Date,
      required: [true, 'Date is required'],
      default: Date.now,
      index: true,
    },
    // For expenses:
    scope: {
      type: String,
      enum: ['personal', 'family'],
      required: function () {
        return this.type === 'expense';
      },
      index: true,
    },
    category: {
      type: String,
      trim: true,
      required: function () {
        return this.type === 'expense';
      },
      index: true,
    },
    // For income:
    source: {
      type: String,
      trim: true,
      required: function () {
        return this.type === 'income';
      },
    },
    // For savings:
    destination: {
      type: String,
      trim: true,
      required: function () {
        return this.type === 'savings';
      },
    },
    description: {
      type: String,
      trim: true,
      default: '',
    },
  },
  {
    timestamps: true,
  }
);

transactionSchema.index({ userId: 1, date: -1 });
transactionSchema.index({ userId: 1, type: 1, date: -1 });
transactionSchema.index({ userId: 1, scope: 1, date: -1 });

module.exports = mongoose.model('Transaction', transactionSchema);
