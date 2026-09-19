const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    name: {
      type: String,
      required: [true, 'Category name is required'],
      trim: true,
    },
    scope: {
      type: String,
      enum: ['personal', 'family'],
      required: [true, 'Scope must be either personal or family'],
      index: true,
    },
    icon: {
      type: String,
      default: 'tag',
      trim: true,
    },
    color: {
      type: String,
      default: '#71717A',
      trim: true,
    },
    isCustom: {
      type: Boolean,
      default: false,
    },
    isDisabled: {
      type: Boolean,
      default: false,
      index: true,
    },
    sortOrder: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

categorySchema.index({ userId: 1, scope: 1, name: 1 }, { unique: true });

module.exports = mongoose.model('Category', categorySchema);
