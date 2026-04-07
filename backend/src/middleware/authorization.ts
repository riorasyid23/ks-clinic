import type { Request, Response, NextFunction } from 'express';
import { insufficientPermissions } from '../utils/errorHelpers.ts';

/**
 * Middleware to check if user has required role(s)
 */
export const requireRole = (roles: string | string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      insufficientPermissions({ reason: 'User not authenticated' });
    }

    const allowedRoles = Array.isArray(roles) ? roles : [roles];
    
    if (!allowedRoles.includes(req.user!.role)) {
      insufficientPermissions({ 
        reason: `User role '${req.user!.role}' does not have access`,
        required_role: allowedRoles
      });
    }

    next();
  };
};

/**
 * Middleware to check if user is ADMIN
 */
export const requireAdmin = requireRole('ADMIN');
