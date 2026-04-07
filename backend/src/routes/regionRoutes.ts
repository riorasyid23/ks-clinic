import express from 'express';
import { authJWT } from '../middleware/JWTAuth.ts';
import { requireAdmin } from '../middleware/authorization.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';
import { createRegion, getRegions } from '../controllers/regionController.ts';

const router = express.Router();

// Get all regions - requires authentication
router.get('/', authJWT, asyncHandler(getRegions));

// Create region - requires authentication and ADMIN role
router.post('/create', authJWT, requireAdmin, asyncHandler(createRegion));

export default router;