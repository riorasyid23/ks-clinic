import { AppError, ErrorCode, ERROR_STATUS_MAP } from './errors.ts';

/**
 * Common error throwing helper functions
 */

export const notFound = (
  resource: string,
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.NOT_FOUND,
    `${resource} not found`,
    { details: details }
  );
};

export const validationFailed = (
  message: string,
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.VALIDATION_FAILED,
    message,
    { details: details }
  );
};

export const missingField = (
  fields: string | string[],
  details?: Record<string, any>
): never => {
  const fieldList = Array.isArray(fields) ? fields.join(', ') : fields;
  throw new AppError(
    ErrorCode.MISSING_FIELD,
    `Missing required field(s): ${fieldList}`,
    { details: details }
  );
};

export const invalidCredentials = (details?: Record<string, any>): never => {
  throw new AppError(
    ErrorCode.INVALID_CREDENTIALS,
    'Invalid email or password',
    { details: details }
  );
};

export const unauthorized = (
  message = 'Unauthorized access',
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.UNAUTHORIZED,
    message,
    { details: details }
  );
};

export const jwtFailedInvalid = (
  message = 'Invalid authentication token',
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.JWT_FAILED_INVALID,
    message,
    { details: details }
  );
};

export const resourceExists = (
  resource: string,
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.RESOURCE_EXISTS,
    `${resource} already exists`,
    { details: details }
  );
};

export const slotNotAvailable = (
  message = 'Selected appointment slot is no longer available',
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.SLOT_NOT_AVAILABLE,
    message,
    { details: details }
  );
};

export const invalidAppointment = (
  message: string,
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.INVALID_APPOINTMENT_TIME,
    message,
    {details}
  )
}

export const appointmentConflict = (
  message = 'Appointment conflicts with existing schedule',
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.APPOINTMENT_CONFLICT,
    message,
    { details: details }
  );
};

export const insufficientPermissions = (
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.INSUFFICIENT_PERMISSIONS,
    'You do not have sufficient permissions to perform this action',
    { details: details }
  );
};

export const operationNotAllowed = (
  message: string,
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.OPERATION_NOT_ALLOWED,
    message,
    { details: details }
  );
};

export const databaseError = (
  originalError?: Error,
  details?: Record<string, any>
): never => {
  const errorDetails: Record<string, any> = { ...details };
  if (originalError?.message) {
    errorDetails.originalError = originalError.message;
  }
  throw new AppError(
    ErrorCode.DATABASE_ERROR,
    'Database operation failed',
    { details: errorDetails }
  );
};

export const internalServerError = (
  message = 'Internal server error',
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.INTERNAL_SERVER_ERROR,
    message,
    { details: details }
  );
};

/**
 * Validate required fields
 */
export const validateRequired = (
  data: Record<string, any>,
  fields: string[]
): void => {
  const missing = fields.filter(field => !data[field]);
  if (missing.length > 0) {
    missingField(missing);
  }
};
