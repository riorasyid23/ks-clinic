import type { Request, Response, NextFunction } from 'express';
import { AppError, isAppError } from '../utils/errors.ts';

/**
 * Generate a unique correlation ID for request tracking
 */
const generateCorrelationId = (req: Request): string => {
  return req.get('x-correlation-id') || `req-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
};

/**
 * Global error handling middleware
 * Must be registered AFTER all other middleware and route handlers
 */
export const errorHandler = (
  error: Error | AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const correlationId = generateCorrelationId(req);

  // Log the error
  console.error(`[${correlationId}] Error:`, {
    name: error.name,
    message: error.message,
    code: isAppError(error) ? error.code : 'UNKNOWN',
    path: req.path,
    method: req.method,
    stack: error.stack,
  });

  // Handle AppError instances
  if (isAppError(error)) {
    error.correlationId = correlationId;
    res.status(error.statusCode).json(error.toJSON());
    return;
  }

  // Handle unexpected errors
  const appError = new AppError(
    'INTERNAL_SERVER_ERROR' as any,
    'An unexpected error occurred',
    {
      correlationId,
      details: {
        originalError: error.message,
      },
    }
  );

  res.status(500).json(appError.toJSON());
};

/**
 * Middleware to pass correlation ID to response headers
 */
export const correlationIdMiddleware = (
  req: Request & { correlationId?: string },
  res: Response,
  next: NextFunction
): void => {
  const correlationId = generateCorrelationId(req);
  req.correlationId = correlationId;
  res.setHeader('x-correlation-id', correlationId);
  next();
};
