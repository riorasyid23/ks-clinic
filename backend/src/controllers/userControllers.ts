import type { Request, Response } from 'express';
import { prisma } from '../lib/prisma.ts';
import {
  missingField,
  invalidCredentials,
  resourceExists,
  databaseError,
} from '../utils/errorHelpers.ts';
import { validateRequired } from '../utils/errorHelpers.ts';
import { updateUserSchema, type UpdateUserInput } from '../schemas/userSchemas.ts';
import { validateRequest } from '../utils/validateRequest.ts';

// For Managing User Profile

export const getUserProfile = async (req: Request, res: Response): Promise<void> => {
  const userId = req.user!.userId;

  let user;
  try {
    user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        patientProfile: true,
        doctorProfile: true,
      },
    });
  } catch (error) {
    databaseError(error as Error);
  }

  if (!user) {
    invalidCredentials();
  }

  res.status(200).json({
    message: 'User profile retrieved successfully',
    user: {
      id: user?.id,
      email: user?.email,
      role: user?.role,
      profile:
        user?.role === 'PATIENT' ? user?.patientProfile : user?.doctorProfile,
    },
  });
}

export const updateUserProfile = async (req: Request, res: Response): Promise<void> => {
  const userId = req.user!.userId;

  const dataToUpdate: any = {};

  for (const key in req.body) {
    if (req.body[key] !== undefined) {
      dataToUpdate[key] = req.body[key];
    }
  }

    // Validate request body with Zod
  const validate = validateRequest(updateUserSchema);
  const validated = validate(dataToUpdate);
  
  const { name, phoneNumber, profileImgUrl, role, height, weight, bloodType, specialty } = validated;

  let updatedUser;
  try {
    switch (role) {
      case 'PATIENT':
        // updatedUser = await prisma.patientProfile.update({
        //   where: { userId: userId },
        //   data: dataToUpdate,
        // });
        updatedUser = await prisma.user.update({
          where: { id: userId },
          data: {
            // name,
            // phoneNumber,
            // profileImgUrl,
            // height,
            // weight,
            // bloodType,
          },
        });
        break;
      case 'DOCTOR':
        updatedUser = await prisma.doctorProfile.update({
          where: { userId: userId },
          data: dataToUpdate
        });
      case 'ADMIN':
        updatedUser = await prisma.user.update({
          where: { id: userId },
          data: dataToUpdate
        });
        break;
    }
  } catch (error) {
    databaseError(error as Error);
  }

  res.status(200).json({
    message: 'User profile updated successfully',
    updatedUser,
  });
};