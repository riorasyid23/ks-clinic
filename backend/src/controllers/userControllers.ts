import type { Request, Response } from 'express';
import { prisma } from '../lib/prisma.ts';
import {
  missingField,
  invalidCredentials,
  resourceExists,
  databaseError,
  notFound,
} from '../utils/errorHelpers.ts';
import { validateRequired } from '../utils/errorHelpers.ts';
import { updateUserSchema, type UpdateUserInput } from '../schemas/userSchemas.ts';
import { validateRequest } from '../utils/validateRequest.ts';
import { isAppError } from '../utils/errors.ts';

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
    if (isAppError(error)) {
        throw error;
    }
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
  const { userId } = req.params as { userId: string };

  if (!userId) {
    missingField('Parameter User ID');
  }

  // Validate request body with Zod
  const validate = validateRequest(updateUserSchema);
  const validated = validate(req.body);
  
  const { name, phoneNumber, profileImgUrl, role, height, weight, bloodType, specialty, regionId } = validated as UpdateUserInput & { regionId?: string };

  try {
    // Get current user to check existing role and profile
    const currentUser = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        patientProfile: true,
        doctorProfile: true,
      },
    });

    if (!currentUser) {
      notFound('User');
    }

    const currentRole = currentUser?.role;
    const newRole = role ?? currentRole;
    const isRoleChanging = newRole !== currentRole;

    // Use transaction to ensure atomic operations
    let updatedUser;
    
    updatedUser = await prisma.$transaction(async (tx) => {
      // Step 1: Handle role transitions if role is changing
      if (isRoleChanging) {
        // Delete old profile based on current role
        if (currentRole === 'PATIENT' && currentUser?.patientProfile) {
          await tx.patientProfile.delete({
            where: { userId },
          });
        } else if (currentRole === 'DOCTOR' && currentUser?.doctorProfile) {
          await tx.doctorProfile.delete({
            where: { userId },
          });
        }
      }

      // Step 2: Prepare profile data
      const profileData: any = {};
      if (name) profileData.name = name;
      if (phoneNumber) profileData.phoneNumber = phoneNumber;
      if (profileImgUrl) profileData.profileImgUrl = profileImgUrl;

      // Step 3: Build user update data
      const userUpdateData: any = {
        role: newRole,
      };

      // Step 4: Handle profile creation/update based on new role
      if (newRole === 'PATIENT') {
        if (bloodType) profileData.bloodType = bloodType;
        if (height) profileData.height = height;
        if (weight) profileData.weight = weight;

        if (isRoleChanging || !currentUser?.patientProfile) {
          // Create new patient profile
          userUpdateData.patientProfile = {
            create: profileData,
          };
        } else {
          // Update existing patient profile
          userUpdateData.patientProfile = {
            update: profileData,
          };
        }
      } else if (newRole === 'DOCTOR') {
        if (specialty) profileData.specialty = specialty;

        if (!regionId && (isRoleChanging || !currentUser?.doctorProfile)) {
          missingField('regionId is required when creating a Doctor profile');
        }

        if (isRoleChanging || !currentUser?.doctorProfile) {
          // Create new doctor profile
          userUpdateData.doctorProfile = {
            create: {
              ...profileData,
              regionId: regionId || currentUser?.doctorProfile?.regionId,
            },
          };
        } else {
          // Update existing doctor profile
          userUpdateData.doctorProfile = {
            update: profileData,
          };
        }
      }

      // Step 5: Update user with new role and profile
      const updatedUserResult = await tx.user.update({
        where: { id: userId },
        data: userUpdateData,
        include: {
          patientProfile: true,
          doctorProfile: true,
        },
      });

      return updatedUserResult;
    });

    res.status(200).json({
      message: 'User profile updated successfully',
      user: {
        id: updatedUser.id,
        email: updatedUser.email,
        role: updatedUser.role,
        profile:
          updatedUser.role === 'PATIENT'
            ? updatedUser.patientProfile
            : updatedUser.doctorProfile,
      },
    });
  } catch (error) {
    if (isAppError(error)) {
        throw error;
    }
    databaseError(error as Error);
  }
};

export const deleteUser = async (req: Request, res: Response): Promise<void> => {
  const { userId } = req.params;

  try {
    await prisma.user.delete({ where: { id: userId as string } });
  } catch (error) {
    if (isAppError(error)) {
        throw error;
    }
    databaseError(error as Error);
  }

  res.status(200).json({
    message: 'User profile deleted successfully',
  });
};