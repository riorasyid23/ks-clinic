import express from 'express';

import { authJWT } from '../middleware/JWTAuth.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';
import { cancelAppointment, createPatientBooking, getEncoDetails, getEncoDoctors, getEncoPatients, getSingleNearestPatientAppointment } from '../controllers/encounterController.ts';

const router = express.Router()

router.get('/patient', authJWT, asyncHandler(getEncoPatients))
router.get('/doctor', authJWT, asyncHandler(getEncoDoctors))

router.post('/patient/create', authJWT, asyncHandler(createPatientBooking))
router.get('/patient/nearest', authJWT, asyncHandler(getSingleNearestPatientAppointment))
router.get('/:encounterId', authJWT, asyncHandler(getEncoDetails))
router.delete('/:encounterId', authJWT, asyncHandler(cancelAppointment))

export default router