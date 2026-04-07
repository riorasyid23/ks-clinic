# Error Handling System Documentation

## Overview

This project uses a centralized, standardized error handling system that ensures consistent error responses across all endpoints. All errors follow this format:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "correlation_id": "req-12345-abc123"
  }
}
```

## Architecture

### 1. **Error Codes & Definition** (`src/utils/errors.ts`)
- Centralized enum of all error codes
- Automatic HTTP status code mapping
- Custom `AppError` class extending JavaScript `Error`

### 2. **Error Handlers** (`src/middleware/errorHandler.ts`)
- Global Express error handling middleware
- Correlation ID tracking for request tracing
- Automatic error formatting and response status

### 3. **Error Helpers** (`src/utils/errorHelpers.ts`)
- Pre-built functions for common error scenarios
- Syntax sugar for throwing typed errors

### 4. **Async Handler** (`src/utils/asyncHandler.ts`)
- Wrapper for async route handlers
- Automatically catches errors and passes to error middleware

## Quick Start

### Basic Usage in Controllers

**Old way (❌):**
```typescript
try {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    res.status(401).json({ error: 'Invalid credentials' });
    return;
  }
} catch (error) {
  console.error('Error:', error);
  res.status(500).json({ error: 'Internal server error' });
}
```

**New way (✅):**
```typescript
import { invalidCredentials, databaseError } from '../utils/errorHelpers.ts';

let user;
try {
  user = await prisma.user.findUnique({ where: { email } });
} catch (error) {
  databaseError(error as Error);
}

if (!user) {
  invalidCredentials();
}
```

### In Routes

```typescript
import { asyncHandler } from '../utils/asyncHandler.ts';

// Wrap async route handlers
router.post('/endpoint', asyncHandler(controller.method));
```

## Available Error Helpers

```typescript
// Validation
missingField(['email', 'password'])
validateRequired({ email, password }, ['email', 'password'])
validationFailed('Invalid input format', { field: 'age' })

// Authentication
invalidCredentials()
unauthorized('You must be logged in')

// Resources
notFound('User')
resourceExists('User with this email')

// Appointments (domain-specific)
slotNotAvailable('Selected time slot is booked')
appointmentConflict('You have a conflicting appointment')

// Permissions
insufficientPermissions()
operationNotAllowed('Patients cannot create appointments for others')

// Server
databaseError(originalError)
internalServerError('Something went wrong')
```

## Error Response Examples

### Missing Field (400)
```json
{
  "error": {
    "code": "MISSING_FIELD",
    "message": "Missing required field(s): email, password",
    "correlation_id": "req-1712489376543-a1b2c3d4e"
  }
}
```

### Invalid Credentials (401)
```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password",
    "correlation_id": "req-1712489376543-a1b2c3d4e"
  }
}
```

### Slot Not Available (409)
```json
{
  "error": {
    "code": "SLOT_NOT_AVAILABLE",
    "message": "Selected appointment slot is no longer available",
    "correlation_id": "req-1712489376543-a1b2c3d4e"
  }
}
```

### Resource Exists (409)
```json
{
  "error": {
    "code": "RESOURCE_EXISTS",
    "message": "User with this email already exists",
    "correlation_id": "req-1712489376543-a1b2c3d4e"
  }
}
```

## Adding Details to Errors

Pass additional context in the `details` parameter:

```typescript
try {
  user = await prisma.user.findUnique({ where: { email } });
} catch (error) {
  databaseError(error as Error, {
    attempted_email: email,
    table: 'users'
  });
}
```

Response:
```json
{
  "error": {
    "code": "DATABASE_ERROR",
    "message": "Database operation failed",
    "correlation_id": "req-...",
    "details": {
      "attempted_email": "user@example.com",
      "table": "users",
      "originalError": "Connection timeout"
    }
  }
}
```

## Creating Custom Errors

While helpers cover most cases, you can create custom errors:

```typescript
import { AppError, ErrorCode } from '../utils/errors.ts';

throw new AppError(
  ErrorCode.SLOT_NOT_AVAILABLE,
  'That time slot has just been booked',
  {
    details: {
      requested_slot: startTime,
      slots_available: availableSlots
    }
  }
);
```

## Extending Error Codes

Add new error codes to `src/utils/errors.ts`:

```typescript
export enum ErrorCode {
  // ... existing codes
  CUSTOM_ERROR = 'CUSTOM_ERROR',
}

export const ERROR_STATUS_MAP: Record<ErrorCode, number> = {
  // ... existing mappings
  [ErrorCode.CUSTOM_ERROR]: 400,
};
```

Then create a helper:

```typescript
export const customError = (
  message: string,
  details?: Record<string, any>
): never => {
  throw new AppError(
    ErrorCode.CUSTOM_ERROR,
    message,
    { details }
  );
};
```

## Correlation IDs for Debugging

Every error response includes a `correlation_id` for request tracing:

```typescript
// Server logs include correlation ID
[req-1712489376543-a1b2c3d4e] Error: INVALID_CREDENTIALS
```

You can also pass correlation ID via request headers:

```bash
curl -H "x-correlation-id: my-custom-id" http://localhost:8080/auth/login
```

## Applying to All Endpoints

### Template: Creating a New Controller

```typescript
// controllers/appointmentController.ts
import { asyncHandler } from '../utils/asyncHandler.ts';
import {
  slotNotAvailable,
  notFound,
  insufficientPermissions,
  validateRequired,
  databaseError,
} from '../utils/errorHelpers.ts';

export const bookAppointment = async (req: Request, res: Response) => {
  const { patientId, doctorId, startTime, endTime } = req.body;

  // Validate
  validateRequired(req.body, ['patientId', 'doctorId', 'startTime', 'endTime']);

  // Check permissions
  if (req.user?.id !== patientId) {
    insufficientPermissions();
  }

  // Fetch data
  let slot;
  try {
    slot = await prisma.appointmentSlot.findUnique({ where: { id: slotId } });
  } catch (error) {
    databaseError(error as Error);
  }

  if (!slot) {
    notFound('Appointment slot');
  }

  if (!slot.available) {
    slotNotAvailable();
  }

  // Create appointment
  const appointment = await prisma.appointment.create({
    data: { /* ... */ }
  });

  res.status(201).json(appointment);
};
```

### Template: Creating a New Route

```typescript
// routes/appointmentRoutes.ts
import express from 'express';
import { bookAppointment, getAppointments } from '../controllers/appointmentController.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';

const router = express.Router();

router.post('/', asyncHandler(bookAppointment));
router.get('/', asyncHandler(getAppointments));

export default router;
```

## Testing Error Responses

```bash
# Test missing fields (400)
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{}'

# Test invalid credentials (401)
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"wrong"}'

# Test resource exists (409)
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"existing@example.com","password":"123456","confirmPassword":"123456"}'
```

## Best Practices

1. **Always wrap async route handlers**: Use `asyncHandler()` in routes
2. **Use helpers over raw errors**: Keeps code consistent and readable
3. **Add context with details**: Help debugging with relevant data
4. **Don't expose sensitive info**: Filter logs before production
5. **Test error paths**: Ensure all error scenarios return proper format
6. **Document custom errors**: Add to this file when creating new error codes

## Troubleshooting

### Errors showing as plain objects instead of formatted responses
- Make sure `asyncHandler()` wraps all async routes
- Verify error handler middleware is registered LAST in `index.ts`

### Correlation ID not appearing
- Check that `correlationIdMiddleware` is registered before routes
- Verify error handler middleware is properly configured

### Type errors with error helpers
- Import error helpers from `'../utils/errorHelpers.ts'`
- Ensure TypeScript strict mode is enabled in `tsconfig.json`

