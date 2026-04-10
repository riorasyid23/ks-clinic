import express from 'express';

import { authJWT } from '../middleware/JWTAuth.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';
import {
    addDoctorSchedules,
    getAvailableAppointmentSlots,
    getDoctorByRegionId,
    getDoctorDetails,
    getDoctorInsights,
    getDoctorSchedules
} from '../controllers/doctorController.ts';

const router = express.Router()

// Static routes first
router.get('/', authJWT, asyncHandler(getDoctorByRegionId));
router.get('/slots', authJWT, asyncHandler(getAvailableAppointmentSlots));

// Parameterized routes later
router.get('/schedules/:doctorId', authJWT, asyncHandler(getDoctorSchedules));
router.get('/:doctorId', authJWT, asyncHandler(getDoctorDetails));

// Root route (listing)

router.post('/schedules', authJWT, asyncHandler(addDoctorSchedules));

export default router