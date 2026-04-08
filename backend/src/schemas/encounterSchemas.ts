import { z } from 'zod';

export const createPatientBookingSchema = z.object({
    date: z.string().min(1, 'Date is Required'),
    reason: z.string().min(1, 'Reason is Required'),
    notes: z.string().optional(),
    patientId: z.string().min(1, 'Patient ID is Required'),
    doctorId: z.string().min(1, 'Doctor ID is Required')
})

export type CreatePatientBooking = z.infer<typeof createPatientBookingSchema>;