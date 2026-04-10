import express from 'express';

import { authJWT } from '../middleware/JWTAuth.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';
import {
    getDoctorInsights,
} from '../controllers/doctorController.ts';

const router = express.Router()

router.get('/', authJWT, asyncHandler(getDoctorInsights));

export default router;