const express = require('express');
const router = express.Router();
const {
  getDashboardSummary,
  getDailyReport,
  getCategoryReport,
  getMonthlyOverview,
} = require('../controllers/reportController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.get('/summary', getDashboardSummary);
router.get('/daily', getDailyReport);
router.get('/categories', getCategoryReport);
router.get('/monthly', getMonthlyOverview);

module.exports = router;
