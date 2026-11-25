const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { userRepository } = require('../repositories');
const { USER_ROLES } = require('../models/constants');

function generateToken(user) {
  return jwt.sign(
    {
      userId: user.user_id,
      email: user.email,
      role: user.role
    },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
}

const authService = {
  async register({ fullName, email, phone, password, role }) {
    const normalizedEmail = email.trim().toLowerCase();
    const validRoles = Object.values(USER_ROLES);

    if (!validRoles.includes(role)) {
      const error = new Error(`Invalid role. Must be one of: ${validRoles.join(', ')}`);
      error.status = 400;
      throw error;
    }

    const existingUser = await userRepository.findByEmail(normalizedEmail);
    if (existingUser) {
      const error = new Error('An account with this email already exists.');
      error.status = 409;
      throw error;
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const createdUser = await userRepository.create({
      fullName: fullName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      passwordHash,
      role
    });

    const token = generateToken(createdUser);

    return {
      user: createdUser,
      token
    };
  },

  async login({ email, password }) {
    const normalizedEmail = email.trim().toLowerCase();
    const user = await userRepository.findByEmail(normalizedEmail);

    if (!user) {
      const error = new Error('Invalid email or password.');
      error.status = 401;
      throw error;
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      const error = new Error('Invalid email or password.');
      error.status = 401;
      throw error;
    }

    const token = generateToken(user);

    // Strip password_hash before returning user object
    const { password_hash, ...safeUser } = user;

    return {
      user: safeUser,
      token
    };
  },

  async getProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) {
      const error = new Error('User not found.');
      error.status = 404;
      throw error;
    }
    return user;
  }
};

module.exports = authService;