import express from 'express';

import { authJWT } from '../middleware/JWTAuth.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';
import { addDoctorSchedules, getAvailableAppointmentSlots, getDoctorByRegionId, getDoctorDetails, getDoctorSchedule, getDoctorSchedules } from '../controllers/doctorController.ts';

const router = express.Router()

router.get('/', authJWT, asyncHandler(getDoctorByRegionId))
router.get('/:doctorId', authJWT, asyncHandler(getDoctorDetails))
router.get('/schedules/:doctorId', authJWT, asyncHandler(getDoctorSchedules))
router.post('/schedules', authJWT, asyncHandler(addDoctorSchedules))

router.get('/slots', authJWT, asyncHandler(getAvailableAppointmentSlots))

export default router