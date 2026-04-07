import type { ZodSchema } from 'zod';
import { ZodError } from 'zod';
import { validationFailed } from './errorHelpers.ts';

/**
 * Validates an object against a Zod schema
 * Throws AppError with formatted validation errors if validation fails
 */
export const validateRequest = <T,>(schema: ZodSchema & { parse: (data: any) => T }): ((data: any) => T) => {
  return (data: any): T => {
    try {
      return schema.parse(data) as T;
    } catch (error) {
      if (error instanceof ZodError) {
        const fieldErrors = error.flatten().fieldErrors;
        const errorMessages = Object.entries(fieldErrors)
          .map(([field, messages]) => {
            const msg = messages as string[] | undefined;
            return `${field}: ${msg?.join(', ') || 'Invalid'}`;
          })
          .join('; ');

        validationFailed(errorMessages, { fieldErrors });
      }
      throw error;
    }
  };
};
