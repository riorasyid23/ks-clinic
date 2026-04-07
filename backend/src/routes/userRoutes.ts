import express from 'express';

import { requireAdmin } from '../middleware/authorization.ts';
import { deleteUser, getUserProfile, updateUserProfile } from '../controllers/userControllers.ts';
import { authJWT } from '../middleware/JWTAuth.ts';

const router = express.Router();

router.get('/profile', authJWT, getUserProfile);
router.put('/:userId', authJWT, requireAdmin, updateUserProfile);
router.delete('/delete', authJWT, requireAdmin, deleteUser);

export default router;