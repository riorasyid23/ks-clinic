import { z } from 'zod';

export const createPatientBookingSchema = z.object({
    date: z.string().min(1, 'Date is Required'),
    startTime: z.string().regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Invalid time format (HH:mm)'),
    reason: z.string().min(1, 'Reason is Required'),
    notes: z.string().optional(),
    doctorProfileId: z.string().min(1, 'Doctor Profile ID is Required')
})

export type CreatePatientBooking = z.infer<typeof createPatientBookingSchema>;