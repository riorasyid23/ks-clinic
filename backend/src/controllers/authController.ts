import type { Request, Response } from 'express';
import { prisma } from '../lib/prisma.ts';
import bcrypt from 'bcrypt';
import { generateAccessToken } from '../helpers/jwt.ts';
import {
  missingField,
  invalidCredentials,
  resourceExists,
  databaseError,
} from '../utils/errorHelpers.ts';
import { validateRequired } from '../utils/errorHelpers.ts';

export const login = async (req: Request, res: Response): Promise<void> => {
  const { email, password } = req.body;

  // Validate required fields
  validateRequired({ email, password }, ['email', 'password']);

  // Query user from database
  let user;
  try {
    user = await prisma.user.findUnique({
      where: { email },
      include: {
        patientProfile: true,
        doctorProfile: true,
      },
    });
  } catch (error) {
    databaseError(error as Error);
  }

  // Check if user exists
  if (!user) {
    invalidCredentials();
  }

  // Compare passwords
  const isPasswordValid = await bcrypt.compare(password, user!.password);

  if (!isPasswordValid) {
    invalidCredentials();
  }

  // Generate JWT token
  const token = generateAccessToken({
    userId: user!.id,
    email: user!.email,
    role: user!.role,
  });

  res.status(200).json({
    message: 'Login successful',
    token,
    user: {
      id: user!.id,
      email: user!.email,
      role: user!.role,
      profile:
        user!.role === 'PATIENT' ? user!.patientProfile : user!.doctorProfile,
    },
  });
};

export const registerUser = async (
  req: Request,
  res: Response
): Promise<void> => {
  const { 
    email,
    password,
    confirmPassword,

    name,
    phoneNumber,
    profileImgUrl,
    height,
    weight,
    bloodType,
    dateOfBirth,
  } = req.body;

  // Validate required fields
  validateRequired({ email, password, confirmPassword, name, phoneNumber }, [
    'email',
    'password',
    'confirmPassword',
    'name',
    'phoneNumber'
  ]);

  // Check if passwords match
  if (password !== confirmPassword) {
    missingField('Passwords do not match');
  }

  // Check if user already exists
  let existingUser;
  try {
    existingUser = await prisma.user.findUnique({ where: { email } });
  } catch (error) {
    databaseError(error as Error);
  }

  if (existingUser) {
    resourceExists('User with this email');
  }

  // Hash password
  const hashedPassword = await bcrypt.hash(password, 10);

  // Create user in database
  let newUser;
  try {
    newUser = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        patientProfile: {
          create: {
            name,
            phoneNumber,
            profileImgUrl,
          }
        }
      },
      include: {
        patientProfile: true,
        doctorProfile: true,
      },
    });
  } catch (error) {
    databaseError(error as Error);
  }

  res.status(201).json({
    message: 'Registration successful',
    user: newUser,
  });
};