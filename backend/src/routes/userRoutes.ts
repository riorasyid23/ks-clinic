import express from 'express';

import { requireAdmin } from '../middleware/authorization.ts';
import { deleteUser, getUserProfile, updateUserProfile } from '../controllers/userControllers.ts';
import { authJWT } from '../middleware/JWTAuth.ts';
import { asyncHandler } from '../utils/asyncHandler.ts';

const router = express.Router();

router.get('/profile', authJWT, asyncHandler(getUserProfile));
router.put('/:userId', authJWT, asyncHandler(updateUserProfile));
router.delete('/delete/:userId', authJWT, asyncHandler(deleteUser));

export default router;