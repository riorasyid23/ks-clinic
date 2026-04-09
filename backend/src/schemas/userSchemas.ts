import { z } from 'zod';

export const updateUserSchema = z.object({
  name: z.string().min(1, 'Name is required').optional(),
  phoneNumber: z.string().min(1, 'Phone number is required').optional(),
  profileImgUrl: z.string().url('Invalid URL format').optional(),
  height: z.number().positive('Height must be a positive number').optional(),
  weight: z.number().positive('Weight must be a positive number').optional(),
  bloodType: z.string().min(1, 'Blood type is required').optional(),
  dateOfBirth: z.string().optional(),
  specialty: z.string().min(1, 'Specialty is required').optional(),
  regionId: z.string().uuid('Invalid region ID format').optional(),
  role: z.enum(['PATIENT', 'DOCTOR', 'ADMIN']).optional(),
});

export const createDoctorScheduleSchema = z.object({
  dayOfWeek: z.enum(['0', '1', '2', '3', '4', '5', '6'], 'Invalid day of week (0-6)'),
  startTime: z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Invalid time format (HH:mm)'),
  endTime: z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Invalid time format (HH:mm)'),
  duration: z.number().positive('Duration must be a positive number'),
});

export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type CreateDoctorScheduleInput = z.infer<typeof createDoctorScheduleSchema>;