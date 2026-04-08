/*
  Warnings:

  - Added the required column `endTime` to the `Encounter` table without a default value. This is not possible if the table is not empty.
  - Added the required column `startTime` to the `Encounter` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Encounter" ADD COLUMN     "endTime" TEXT NOT NULL,
ADD COLUMN     "startTime" TEXT NOT NULL;
