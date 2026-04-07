import express from 'express';

import { requireAdmin } from '../middleware/authorization.ts';
import { getUserProfile, updateUserProfile } from '../controllers/userControllers.ts';
import { authJWT } from '../middleware/JWTAuth.ts';

const router = express.Router();

router.get('/profile', authJWT, getUserProfile);
router.put('/update', authJWT, updateUserProfile);

export default router;