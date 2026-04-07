import { z } from 'zod';

export const updateUserSchema = z.object({
  name: z.string().min(1, 'Name is required').optional(),
  phoneNumber: z.string().min(1, 'Phone number is required').optional(),
  profileImgUrl: z.string().url('Invalid URL format').optional(),
  height: z.number().positive('Height must be a positive number').optional(),
  weight: z.number().positive('Weight must be a positive number').optional(),
  bloodType: z.string().min(1, 'Blood type is required').optional(),
  specialty: z.string().min(1, 'Specialty is required').optional(),
  regionId: z.string().uuid('Invalid region ID format').optional(),
  role: z.enum(['PATIENT', 'DOCTOR', 'ADMIN']).optional(),
});

export type UpdateUserInput = z.infer<typeof updateUserSchema>;