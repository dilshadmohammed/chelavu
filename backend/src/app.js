const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const authRoutes = require('./routes/authRoutes');
const categoryRoutes = require('./routes/categoryRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const reportRoutes = require('./routes/reportRoutes');

const app = express();

// Enable CORS for mobile app, web app, local dev, and Vercel domains
app.use(
  cors({
    origin: true, // Allow all origins for the personal multi-device finance client
    credentials: true,
  })
);

app.use(express.json());

// Database connection middleware (critical for Vercel serverless lifecycle)
app.use(async (req, res, next) => {
  try {
    await connectDB();
    next();
  } catch (err) {
    console.error('Database connection failed on request:', err.message);
    res.status(500).json({
      success: false,
      message: 'Database connection failed. Please check MONGODB_URI.',
    });
  }
});

// Root & Health Check
app.get('/', (req, res) => {
  res.json({
    app: 'CheLav API',
    status: 'online',
    version: '1.0.0',
    description: 'Personal and Family Finance Tracking Backend',
    endpoints: {
      auth: '/api/auth',
      categories: '/api/categories',
      transactions: '/api/transactions',
      reports: '/api/reports',
    },
  });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Mount API routes
app.use('/api/auth', authRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/transactions', transactionRoutes);
app.use('/api/reports', reportRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route not found: ${req.method} ${req.originalUrl}`,
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
  });
});

module.exports = app;
