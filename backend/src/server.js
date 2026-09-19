require('dotenv').config();
const app = require('./app');
const connectDB = require('./config/db');

const PORT = process.env.PORT || 5001;

async function startServer() {
  try {
    await connectDB();
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`========================================`);
      console.log(`  CheLav Server running on port ${PORT}  `);
      console.log(`  Local URL: http://localhost:${PORT}    `);
      console.log(`========================================`);
    });
  } catch (err) {
    console.error('Failed to start server:', err.message);
    process.exit(1);
  }
}

startServer();
