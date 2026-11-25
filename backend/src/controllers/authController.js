const authService = require('../services/authService');

const authController = {
  async register(req, res, next) {
    try {
      const { full_name, email, phone, password, role } = req.body;

      if (!full_name || !email || !phone || !password || !role) {
        return res.status(400).json({
          success: false,
          message: 'full_name, email, phone, password, and role are required.'
        });
      }

      if (password.length < 6) {
        return res.status(400).json({
          success: false,
          message: 'Password must be at least 6 characters long.'
        });
      }

      const result = await authService.register({
        fullName: full_name,
        email,
        phone,
        password,
        role
      });

      res.status(201).json({
        success: true,
        message: 'User registered successfully',
        data: result
      });
    } catch (error) {
      next(error);
    }
  },

  async login(req, res, next) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          success: false,
          message: 'Email and password are required.'
        });
      }

      const result = await authService.login({ email, password });

      res.status(200).json({
        success: true,
        message: 'Login successful',
        data: result
      });
    } catch (error) {
      next(error);
    }
  },

  async getMe(req, res, next) {
    try {
      const user = await authService.getProfile(req.user.userId);
      res.status(200).json({
        success: true,
        message: 'User profile retrieved',
        data: user
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = authController;