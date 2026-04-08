import type { Request, Response } from 'express';
import { prisma } from '../lib/prisma.ts';
import {
  missingField,
  invalidCredentials,
  resourceExists,
  databaseError,
  notFound,
  validationFailed,
  unauthorized
} from '../utils/errorHelpers.ts';
import { validateRequest } from '../utils/validateRequest.ts';
import { createPatientBookingSchema } from '../schemas/encounterSchemas.ts';

export const getEncoPatients = async (req: Request, res: Response): Promise<void> => {
    const userId = req.user?.userId
    const role = req.user?.role

    if(role !== 'PATIENT'){
        unauthorized("For Patient Only")
    }

    try {
        const bookings = await prisma.encounter.findMany({
            where: {
                patientId: userId as string
            }
        })

        if(!bookings){
            return notFound('Booking Patients')
        }

        res.status(200).json({
            message: 'Bookings Data retrieved!',
            bookings
        })
    } catch (error) {
        databaseError(error as Error)
    }
}

export const getEncoDoctors = async (req: Request, res: Response): Promise<void> => {
    const userId = req.user?.userId
    const role = req.user?.role

    if(role !== 'DOCTOR'){
        unauthorized("For Doctor Only")
    }

    try {
        const bookings = await prisma.encounter.findMany({
            where: {
                doctorId: userId as string
            }
        })

        if(!bookings){
            return notFound('Doctor Appointments')
        }

        res.status(200).json({
            message: 'Appointments Data retrieved!',
            bookings
        })
    } catch (error) {
        databaseError(error as Error)
    }
}

export const createPatientBooking = async (req: Request, res: Response): Promise<void> => {
    const { userId, role } = req.user!

    if(role !== 'PATIENT'){
        return unauthorized('Patient Only')
    }

    const validate = validateRequest(createPatientBookingSchema)
    const validated = validate(req.body)

    const { date, reason, notes, patientId, doctorId } = validated

    try {
        // Check Available Slots TODO

        // Create Booking
        const booking = await prisma.encounter.create({
            data: {
                date: new Date(date as string),
                reason,
                notes: notes ?? '',
                patientId,
                doctorId
            }
        })

        res.status(201).json({
            message: "Booking is created!",
            booking
        })
    } catch (error) {
        databaseError(error as Error)
    }
}