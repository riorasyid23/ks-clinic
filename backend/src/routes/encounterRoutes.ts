import express from 'express';

import { authJWT } from '../middleware/JWTAuth.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';
import { createPatientBooking, getEncoDoctors, getEncoPatients } from '../controllers/encounterController.ts';

const router = express.Router()

router.get('/patient', authJWT, asyncHandler(getEncoPatients))
router.get('/doctor', authJWT, asyncHandler(getEncoDoctors))

router.post('/patient/create', authJWT, asyncHandler(createPatientBooking))

export default router