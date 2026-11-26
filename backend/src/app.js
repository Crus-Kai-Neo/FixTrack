const express = require('express');
const cors = require('cors');
const { getPool } = require('./config/database');
const authRoutes = require('./routes/authRoutes');
const shopRoutes = require('./routes/shopRoutes');
const requestRoutes = require('./routes/requestRoutes');
const estimateRoutes = require('./routes/estimateRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');

const app = express();

// Core middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health-check endpoints
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'FixTrack API is running',
    data: {
      environment: process.env.NODE_ENV || 'development',
      timestamp: new Date().toISOString()
    }
  });
});

app.get('/api/health/db', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT 1 AS dbCheck');
    res.status(200).json({
      success: true,
      message: 'SQL Server connection successful',
      data: result.recordset[0]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'SQL Server connection failed',
      error: error.message
    });
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/shops', shopRoutes);
app.use('/api/requests', requestRoutes);
app.use('/api/estimates', estimateRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/dashboard', dashboardRoutes);

// 404 handler for unknown routes
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error'
  });
});

module.exports = app;