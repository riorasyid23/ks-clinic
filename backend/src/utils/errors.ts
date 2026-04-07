/**
 * Standardized error codes for the application
 */
const ERROR_CODES = {
  // Authentication errors
  INVALID_CREDENTIALS: 'INVALID_CREDENTIALS',
  UNAUTHORIZED: 'UNAUTHORIZED',
  JWT_FAILED_INVALID: 'JWT_FAILED_INVALID',
  TOKEN_EXPIRED: 'TOKEN_EXPIRED',
  MISSING_TOKEN: 'MISSING_TOKEN',

  // Validation errors
  VALIDATION_FAILED: 'VALIDATION_FAILED',
  INVALID_INPUT: 'INVALID_INPUT',
  MISSING_FIELD: 'MISSING_FIELD',

  // Resource errors
  NOT_FOUND: 'NOT_FOUND',
  RESOURCE_EXISTS: 'RESOURCE_EXISTS',
  RESOURCE_IN_USE: 'RESOURCE_IN_USE',

  // Appointment errors
  SLOT_NOT_AVAILABLE: 'SLOT_NOT_AVAILABLE',
  APPOINTMENT_CONFLICT: 'APPOINTMENT_CONFLICT',
  INVALID_APPOINTMENT_TIME: 'INVALID_APPOINTMENT_TIME',

  // Business logic errors
  OPERATION_NOT_ALLOWED: 'OPERATION_NOT_ALLOWED',
  INSUFFICIENT_PERMISSIONS: 'INSUFFICIENT_PERMISSIONS',

  // Server errors
  DATABASE_ERROR: 'DATABASE_ERROR',
  INTERNAL_SERVER_ERROR: 'INTERNAL_SERVER_ERROR',
} as const;

export type ErrorCode = typeof ERROR_CODES[keyof typeof ERROR_CODES];
export const ErrorCode = ERROR_CODES;

/**
 * HTTP status codes mapped to error codes
 */
export const ERROR_STATUS_MAP: Record<ErrorCode, number> = {
  [ERROR_CODES.INVALID_CREDENTIALS]: 401,
  [ERROR_CODES.UNAUTHORIZED]: 401,
  [ERROR_CODES.JWT_FAILED_INVALID]: 401,
  [ERROR_CODES.TOKEN_EXPIRED]: 401,
  [ERROR_CODES.MISSING_TOKEN]: 401,

  [ERROR_CODES.VALIDATION_FAILED]: 400,
  [ERROR_CODES.INVALID_INPUT]: 400,
  [ERROR_CODES.MISSING_FIELD]: 400,

  [ERROR_CODES.NOT_FOUND]: 404,
  [ERROR_CODES.RESOURCE_EXISTS]: 409,
  [ERROR_CODES.RESOURCE_IN_USE]: 409,

  [ERROR_CODES.SLOT_NOT_AVAILABLE]: 409,
  [ERROR_CODES.APPOINTMENT_CONFLICT]: 409,
  [ERROR_CODES.INVALID_APPOINTMENT_TIME]: 400,

  [ERROR_CODES.OPERATION_NOT_ALLOWED]: 403,
  [ERROR_CODES.INSUFFICIENT_PERMISSIONS]: 403,

  [ERROR_CODES.DATABASE_ERROR]: 500,
  [ERROR_CODES.INTERNAL_SERVER_ERROR]: 500,
};

/**
 * Custom error class for consistent error handling
 */
export class AppError extends Error {
  code: ErrorCode;
  statusCode: number;
  correlationId: string | undefined;
  details: Record<string, any> | undefined;

  constructor(
    code: ErrorCode,
    message: string,
    options?: {
      statusCode?: number;
      correlationId?: string | undefined;
      details?: Record<string, any> | undefined;
    }
  ) {
    super(message);
    this.code = code;
    this.statusCode = options?.statusCode || ERROR_STATUS_MAP[code];
    this.correlationId = options?.correlationId;
    this.details = options?.details;
    this.name = 'AppError';

    // Maintains proper stack trace for where our error was thrown
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor);
    }
  }

  /**
   * Convert error to JSON response format
   */
  toJSON() {
    return {
      error: {
        code: this.code,
        message: this.message,
        // correlation_id: this.correlationId,
        ...(this.details && { details: this.details }),
      },
    };
  }
}

/**
 * Type guard to check if error is AppError
 */
export const isAppError = (error: any): error is AppError => {
  return error instanceof AppError;
};
