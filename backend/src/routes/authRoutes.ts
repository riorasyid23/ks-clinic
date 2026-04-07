import express from 'express';
import { login, registerUser } from '../controllers/authController.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';

const router = express.Router();

/**
 * POST /auth/login
 * Login endpoint
 * Body: { email: string, password: string }
 */
router.post('/login', asyncHandler(login));

/**
 * POST /auth/register
 * Register endpoint
 * Body: { email: string, password: string, confirmPassword: string }
 */
router.post('/register', asyncHandler(registerUser));

export default router;
