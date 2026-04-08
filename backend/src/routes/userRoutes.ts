import express from 'express';

import { requireAdmin } from '../middleware/authorization.ts';
import { deleteUser, getUserProfile, updateUserProfile } from '../controllers/userControllers.ts';
import { authJWT } from '../middleware/JWTAuth.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';

const router = express.Router();

router.get('/profile', authJWT, asyncHandler(getUserProfile));
router.put('/:userId', authJWT, requireAdmin, asyncHandler(updateUserProfile));
router.delete('/delete', authJWT, requireAdmin, asyncHandler(deleteUser));

export default router;