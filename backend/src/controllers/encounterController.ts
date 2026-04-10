import type { Request, Response } from 'express';
import { prisma } from '../lib/prisma.ts';
import {
    missingField,
    invalidCredentials,
    resourceExists,
    databaseError,
    notFound,
    validationFailed,
    unauthorized,
    slotNotAvailable,
    invalidAppointment,
    operationNotAllowed
} from '../utils/errorHelpers.ts';
import { validateRequest } from '../utils/validateRequest.ts';
import { createPatientBookingSchema } from '../schemas/encounterSchemas.ts';
import { addMinutes, differenceInMinutes, format, parse } from 'date-fns';
import { AppError, isAppError } from '../utils/errors.ts';
import type { Encounter } from '../generated/prisma/client.ts';

export const getEncoPatients = async (req: Request, res: Response): Promise<void> => {
    const userId = req.user?.userId
    const role = req.user?.role

    if (role !== 'PATIENT') {
        unauthorized("For Patient Only")
    }

    try {
        // Get Patient Profile
        const patientProfile = await prisma.patientProfile.findUnique({
            where: {
                userId: userId as string
            },
            include: {
                appointments: {
                    include: {
                        doctor: {
                            include: {
                                user: {
                                    include: {
                                        doctorProfile: true
                                    }
                                }
                            }
                        }
                    },
                    orderBy: {
                        createdAt: 'desc'
                    }
                },

            }
        })

        const bookingAppointments = patientProfile?.appointments.map((a) => ({
            id: a.id,
            date: a.date,
            startTime: a.startTime,
            endTime: a.endTime,
            currentStatus: a.currentStatus,
            reason: a.reason,
            doctor: {
                name: a.doctor.user.doctorProfile?.name,
                specialty: a.doctor.user.doctorProfile?.specialty,

            },
            createdAt: a.createdAt
        }))


        if (bookingAppointments?.length === 0) {
            return notFound('Booking Patients')
        }

        res.status(200).json({
            message: 'Bookings Data retrieved!',
            bookings: bookingAppointments
        })
    } catch (error) {
        if (isAppError(error)) {
            throw error;
        }
        databaseError(error as Error);
    }
}

export const getEncoDoctors = async (req: Request, res: Response): Promise<void> => {
    const userId = req.user?.userId
    const role = req.user?.role

    if (role !== 'DOCTOR') {
        unauthorized("For Doctor Only")
    }

    try {
        const doctorProfile = await prisma.doctorProfile.findUnique({
            where: {
                userId: userId as string
            },
            include: {
                appointments: true
            }
        })

        const bookingAppointments = doctorProfile?.appointments.map((a) => ({
            id: a.id,
            date: a.date,
            startTime: a.startTime,
            endTime: a.endTime,
            currentStatus: a.currentStatus,
            // reason: a.reason,
            // notes: a.notes,
            // patientId: a.patientId,
            // doctorId: a.doctorId,
            createdAt: a.createdAt
        }))

        if (bookingAppointments?.length === 0) {
            return notFound('Doctor Appointments')
        }

        res.status(200).json({
            message: 'Appointments Data retrieved!',
            bookings: bookingAppointments
        })
    } catch (error) {
        if (isAppError(error)) {
            throw error;
        }
        databaseError(error as Error);
    }
}

// Get Nearest Patient Appointment
export const getSingleNearestPatientAppointment = async (req: Request, res: Response): Promise<void> => {
    const userId = req.user?.userId
    const role = req.user?.role

    if (role !== 'PATIENT') {
        unauthorized("For Patient Only")
    }

    try {
        const patientProfile = await prisma.patientProfile.findUnique({
            where: {
                userId: userId as string
            },
            include: {
                appointments: {
                    where: {
                        date: {
                            gte: new Date()
                        },
                        currentStatus: {
                            notIn: ['CANCELLED', 'COMPLETED']
                        }
                    },
                    include: {
                        doctor: true
                    },
                    orderBy: {
                        date: 'asc'
                    }
                }
            }
        })

        const today = new Date()
        const currentHour = today.getHours()
        const currentMinute = today.getMinutes()

        const currentTime = `${currentHour}:${currentMinute}`
        const timeNow = parse(currentTime, 'HH:mm', new Date())

        const nearestAppointment = patientProfile?.appointments.find((a) => {
            const appointmentDate = new Date(a.date)
            const appointmentTime = parse(a.startTime, 'HH:mm', new Date())
            return appointmentDate >= today
        })

        if (!nearestAppointment) {
            return notFound('Patient Appointments')
        }

        res.status(200).json({
            message: 'Next Appointment Data retrieved!',
            bookings: nearestAppointment
        })
    } catch (error) {
        if (isAppError(error)) {
            throw error;
        }
        databaseError(error as Error);
    }
}

export const getEncoDetails = async (req: Request, res: Response): Promise<void> => {
    const { encounterId } = req.params

    if (!encounterId) {
        return missingField('Parameter Encounter ID')
    }

    try {
        const encounter = await prisma.encounter.findUnique({
            where: {
                id: encounterId as string
            },
            include: {
                statusTimeline: {
                    orderBy: {
                        createdAt: 'desc'
                    }
                },
                doctor: {
                    include: {
                        user: {
                            include: {
                                doctorProfile: true
                            }
                        }
                    }
                }
            }
        })

        if (!encounter) {
            return notFound("Appointment Data")
        }

        res.status(200).json({
            message: "Appointment data found!",
            details: {
                id: encounter.id,
                date: encounter.date,
                startTime: encounter.startTime,
                endTime: encounter.endTime,
                currentStatus: encounter.currentStatus,
                reason: encounter.reason,
                notes: encounter.notes,
                createdAt: encounter.createdAt,
                doctor: {
                    name: encounter.doctor.user.doctorProfile?.name,
                    specialty: encounter.doctor.user.doctorProfile?.specialty,
                    phone: encounter.doctor.user.doctorProfile?.phoneNumber,
                },
                statusTimeline: encounter.statusTimeline,
            }
        })

    } catch (error) {
        if (isAppError(error)) {
            throw error
        }
        databaseError(error as Error)
    }
}

export const createPatientBooking = async (req: Request, res: Response): Promise<void> => {
    const { userId, role } = req.user!

    if (role !== 'PATIENT') {
        return unauthorized('Patient Only')
    }

    const validate = validateRequest(createPatientBookingSchema)
    const validated = validate(req.body)

    const { date, startTime, reason, notes, doctorProfileId } = validated

    try {
        const patientProfile = await prisma.patientProfile.findUnique({
            where: {
                userId: userId as string
            }
        })

        if (!patientProfile) {
            return notFound('Patient Profile')
        }

        // Check Available Slots
        const existingBooking = await prisma.encounter.findFirst({
            where: {
                doctorId: doctorProfileId,
                date: new Date(date as string),
                startTime: startTime,
                currentStatus: { not: 'CANCELLED' }
            }
        })


        if (existingBooking) {
            return resourceExists('Someone booking this slot')
        }

        // Create Booking
        const result = await prisma.$transaction(async (tx) => {

            const schedule = await prisma.doctorSchedule.findFirst({
                where: {
                    doctorId: doctorProfileId,
                    dayOfWeek: new Date(date as string).getDay()
                }
            });

            if (!schedule) {
                return slotNotAvailable('Doctor does not work on this day');
            }

            const bookStartReqTime = parse(startTime, 'HH:mm', new Date());
            const endDateTime = addMinutes(bookStartReqTime, schedule.slotDuration);
            const bookEndReqTime = format(endDateTime, 'HH:mm');

            const scheduleStart = parse(schedule.startTime, 'HH:mm', new Date())
            const scheduleEnd = parse(schedule.endTime, 'HH:mm', new Date())

            if (bookStartReqTime < scheduleStart || bookStartReqTime >= scheduleEnd) {
                return slotNotAvailable(`Requested time is outside of doctor's working hours.`)
            }

            const diffInMinutes = differenceInMinutes(bookStartReqTime, scheduleStart);
            if (diffInMinutes % schedule.slotDuration !== 0) {
                return invalidAppointment('Invalid slot interval.')
            }

            // Create the Encounter
            const booking = await tx.encounter.create({
                data: {
                    date: new Date(date as string),
                    startTime,
                    endTime: bookEndReqTime,
                    reason,
                    notes: notes ?? '',
                    patientId: patientProfile.id,
                    doctorId: doctorProfileId,
                    currentStatus: 'PENDING',
                    statusTimeline: {
                        create: {
                            status: 'PENDING',
                            createdBy: `${role}-${userId}`,
                            note: `Initial booking created by ${role.toLowerCase()}`
                        }
                    }
                },
                include: {
                    statusTimeline: true
                }
            });

            return booking;
        });

        res.status(201).json({
            message: "Booking is created!",
            booking: result
        })
    } catch (error) {
        if (isAppError(error)) {
            throw error;
        }
        databaseError(error as Error);
    }
}

export const cancelAppointment = async (req: Request, res: Response): Promise<void> => {
    const userId = req.user?.userId
    const role = req.user?.role
    const { encounterId } = req.params

    if (!encounterId) {
        return missingField("Parameter Encounter ID")
    }

    try {
        const encounter = await prisma.encounter.findUnique({
            where: {
                id: encounterId as string,
            },
            include: {
                statusTimeline: true
            }
        })

        if (!encounter) {
            return notFound("Encounter Data")
        }

        const isConfirmed = encounter.statusTimeline.some((e) =>
            e.status === 'CONFIRMED' ||
            e.status === 'COMPLETED' ||
            e.status === 'CANCELLED'
        )

        if (isConfirmed) {
            return operationNotAllowed('Cannot cancelled a confirmed/completed or already cancelled appointment')
        }

        const result = await prisma.$transaction(async (tx) => {
            const currentAppointment = await tx.encounter.update({
                where: {
                    id: encounter.id
                },
                data: {
                    currentStatus: 'CANCELLED',
                },
                include: {
                    statusTimeline: true
                }
            })

            const statusUpdate = await tx.statusUpdate.create({
                data: {
                    encounterId: encounter.id,
                    createdBy: `${role}-${userId}`,
                    status: 'CANCELLED',
                    note: req.body.note ?? ""
                }
            })

            currentAppointment.statusTimeline.push(statusUpdate)

            return currentAppointment
        })



        res.status(201).json({
            message: "Appointment is Cancelled!",
            result,
        })
    } catch (error) {
        if (isAppError(error)) {
            throw error
        }
        databaseError(error as Error)
    }
}