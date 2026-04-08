import type { Request, Response } from 'express';
import { prisma } from '../lib/prisma.ts';
import {
  resourceExists,
  databaseError,
  notFound,
} from '../utils/errorHelpers.ts';
import { validateRequest } from '../utils/validateRequest.ts';
import { createRegionSchema } from '../schemas/regionSchemas.ts';
import { isAppError } from '../utils/errors.ts';

export const getRegions = async (req: Request, res: Response): Promise<void> => {
  let regions;
  try {
    regions = await prisma.region.findMany();
  } catch (error) {
    if (isAppError(error)) {
        throw error;
    }
    databaseError(error as Error);
  }

  res.status(200).json({
    message: 'Regions retrieved successfully',
    data: regions,
  });
};

export const createRegion = async (req: Request, res: Response): Promise<void> => {
  // Validate request body with Zod
  const validate = validateRequest(createRegionSchema);
  const validated = validate(req.body);

  const { name, city, address, mapUrl, regionImgUrl } = validated;

  // Check if region already exists
  let existingRegion;
  try {
    existingRegion = await prisma.region.findUnique({
      where: { name },
    });
  } catch (error) {
    if (isAppError(error)) {
        throw error;
    }
    databaseError(error as Error);
  }

  if (existingRegion) {
    resourceExists('Region with this name');
  }

  // Create new region
  let newRegion;
  try {
    newRegion = await prisma.region.create({
      data: { 
        name, 
        city, 
        address, 
        mapUrl: mapUrl ?? null, 
        regionImgUrl: regionImgUrl ?? null 
      },
    });
  } catch (error) {
    if (isAppError(error)) {
        throw error;
    }
    databaseError(error as Error);
  }

  res.status(201).json({
    message: 'Region created successfully',
    data: newRegion,
  });
};