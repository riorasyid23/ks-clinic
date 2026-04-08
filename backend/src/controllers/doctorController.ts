import type { Request, Response } from 'express';
import { prisma } from '../lib/prisma.ts';
import {
  missingField,
  invalidCredentials,
  resourceExists,
  databaseError,
  notFound,
  validationFailed
} from '../utils/errorHelpers.ts';
import { validateRequest } from '../utils/validateRequest.ts';
import { createDoctorScheduleSchema } from '../schemas/userSchemas.ts';
import { addMinutes, format, parse } from 'date-fns';
import { calculateAvailableSlots } from '../helpers/calculateAvailableSlots.ts';

export const getDoctorByRegionId = async (req: Request, res: Response): Promise<void> => {
  const { regionId } = req.query;

  if (!regionId) {
    missingField('Parameter Region ID');
  }

  let doctors;
  try {
    doctors = await prisma.doctorProfile.findMany({
      where: { regionId: regionId as string },
      include: {
        user: true,
        region: true,
      },
    });
  } catch (error) {
    databaseError(error as Error);
  }

  res.status(200).json({
    message: 'Doctors retrieved successfully',
    doctors: doctors?.map((doctor) => ({
      id: doctor.id,
      name: doctor.name,
      specialty: doctor.specialty,
      profileImgUrl: doctor.profileImgUrl,
      region: doctor.region.name,
      userEmail: doctor.user.email,
    })),
  });
};

export const getDoctorSchedule = async (req: Request, res: Response): Promise<void> => {
    const doctorId = req.params.doctorId;

    if (!doctorId) {
        missingField('Parameter Doctor ID');
    }

    let schedules;
    try {
        schedules = await prisma.doctorSchedule.findMany({
            where: { doctorId: doctorId as string },
            select: {
                id: true,
                dayOfWeek: true,
                startTime: true,
                endTime: true,
                slotDuration: true
            }
        });
    } catch (error) {
        databaseError(error as Error);
    }

    res.status(200).json({
        message: 'Doctor schedule retrieved successfully',
        schedules: schedules
    });
}

export const addDoctorSchedules = async (req: Request, res: Response): Promise<void> => {
    const userId = req.user?.userId
    const role = req.user?.role

    if(role !== 'DOCTOR') {
        validationFailed('Only doctors can add schedules');
    }

    const validate = validateRequest(createDoctorScheduleSchema);
    const validated = validate(req.body);

    const { dayOfWeek, startTime, endTime, duration } = validated;
    
    const parsedDayOfWeek = parseInt(dayOfWeek);

    if (isNaN(parsedDayOfWeek) || parsedDayOfWeek < 0 || parsedDayOfWeek > 6) {
        validationFailed('Invalid day of week. Must be an integer between 0 (Sunday) and 6 (Saturday).');
    }

    try {
        // Get the DoctorProfile ID from the authenticated user
        const doctorProfile = await prisma.doctorProfile.findUnique({
            where: { userId: userId as string }
        });

        if (!doctorProfile) {
            notFound('Doctor profile');
            return;
        }

        const doctorId = doctorProfile.id;

        const isDayExists = await prisma.doctorSchedule.findFirst({
            where: {
                doctorId: doctorId,
                dayOfWeek: parsedDayOfWeek
            }
        })

        if(isDayExists) {
            validationFailed('Schedule for the specified day already exists for this doctor');
        }

        // Validate Start and End Time
        const start = new Date(`1970-01-01T${startTime}:00Z`);
        const end = new Date(`1970-01-01T${endTime}:00Z`);

        if (isNaN(start.getTime()) || isNaN(end.getTime())) {
            invalidCredentials({ details: 'Invalid time format. Expected HH:mm' });
        }

        if (start >= end) {
            ({ details: 'Start time must be before end time' });
        }

        const schedule = await prisma.doctorSchedule.create({
            data: {
                doctorId: doctorId as string,
                dayOfWeek: parsedDayOfWeek,
                startTime,
                endTime,
                slotDuration: duration
            }
        })

        res.status(201).json({
            message: 'Schedule added successfully',
            schedule: {
                id: schedule.id,
                dayOfWeek: schedule.dayOfWeek,
                startTime: schedule.startTime,
                endTime: schedule.endTime,
                slotDuration: schedule.slotDuration
            }
        })
    } catch (error) {
        databaseError(error as Error);
    }
}

export const getDoctorSchedules = async (req: Request, res: Response): Promise<void> => {
    const { doctorId } = req.params

    if(!doctorId){
        missingField("Parameter doctorId")
    }

    try {
        const doctor = await prisma.doctorProfile.findUnique({
            where: {
                userId: doctorId as string,

            },
            include: {
                schedule: true
            }
        })

        if(!doctor){
            notFound("Doctor data")
        }

        if(doctor?.schedule.length === 0){
            notFound("Doctor schedule")
        }

        const schedules = doctor?.schedule.map((s) => ({
            id: s.id,
            dayOfWeek: s.dayOfWeek,
            startTime: s.startTime,
            endTime: s.endTime,
            duration: s.slotDuration
            
        }))

        res.status(200).json({
            message: "Doctor schedules successfully retrieved!",
            schedules
        })
        
    } catch (error) {
        databaseError(error as Error)
    }
}

export const getAvailableAppointmentSlots = async (req: Request, res: Response): Promise<void> => {
    const { doctorProfileId, date } = req.query;
    const newDate = new Date(date as string);
    const dayOfWeek = newDate.getDay();

    if (!doctorProfileId) {
        missingField('Query Parameter Doctor ID');
    }

    if (!date) {
        missingField('Query Parameter Date');
    }

    try {
        const schedule = await prisma.doctorSchedule.findFirst({
            where: {
                doctorId: doctorProfileId as string,
                dayOfWeek: dayOfWeek
            },
            
        });

        if (!schedule) {
            return notFound('Schedule for the specified doctor and date');
        }

         // Logic to calculate available slots based on schedules and existing appointments would go here
        const existingBookings = await prisma.encounter.findMany({
            where: {
                doctorId: doctorProfileId as string,
                date: {
                    gte: new Date(`${date}T00:00:00.000Z`),
                    lte: new Date(`${date}T23:59:59.999Z`)
                },
                currentStatus: { not: 'CANCELLED' }
                
            },
        });

        const availableSlots = calculateAvailableSlots(
            schedule.startTime,
            schedule.endTime,
            schedule.slotDuration,
            existingBookings
        );
        // let currentTime = parse(schedule.startTime, 'HH:mm', new Date());
        // const endTime = parse(schedule.endTime, 'HH:mm', new Date());

        // while (currentTime < endTime) {
        //     const timeString = format(currentTime, 'HH:mm');

        //     const isBooked = existingBookings.some(booking => format(booking.date, 'HH:mm') === timeString);

        //     if (!isBooked) {
        //         availableSlots.push(timeString);
        //     }

        //     currentTime = addMinutes(currentTime, schedule.slotDuration);
        // }

        res.status(200).json({
            message: 'Available appointment slots retrieved successfully',
            slots: availableSlots 
        });
    } catch (error) {
        databaseError(error as Error);
    }
}