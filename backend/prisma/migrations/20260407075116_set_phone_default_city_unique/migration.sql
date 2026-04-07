/*
  Warnings:

  - A unique constraint covering the columns `[name]` on the table `RegionCity` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "DoctorProfile_phoneNumber_key";

-- DropIndex
DROP INDEX "PatientProfile_phoneNumber_key";

-- CreateIndex
CREATE UNIQUE INDEX "RegionCity_name_key" ON "RegionCity"("name");
