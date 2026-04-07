import type { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { unauthorized } from '../utils/errorHelpers.ts';

declare global {
  namespace Express {
    interface Request {
      user?: {
        userId: string;
        email: string;
        role: string;
      };
    }
  }
}

export const authJWT = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      unauthorized('No token provided');
    }

    const authSecret = process.env.AUTH_SECRET;
    if (!authSecret) {
      throw new Error('AUTH_SECRET environment variable is not set');
    }

    jwt.verify(token!, authSecret as string, (err: any, decoded: any) => {
      if (err) {
        unauthorized('Invalid or expired token');
      }

      // Attach user info to request
      req.user = decoded as { userId: string; email: string; role: string };
      next();
    });
  } catch (err) {
    next(err);
  }
};
