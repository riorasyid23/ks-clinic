import { z } from 'zod';

/**
 * Schema for creating a region
 */
export const createRegionSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  city: z.string().min(1, 'City is required'),
  address: z.string().min(1, 'Address is required'),
  mapUrl: z.string().nullable().optional().transform(val => val ?? null),
  regionImgUrl: z.string().nullable().optional().transform(val => val ?? null),
});

export type CreateRegionInput = z.infer<typeof createRegionSchema>;
