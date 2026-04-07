/*
  Warnings:

  - You are about to drop the column `regionCityId` on the `DoctorProfile` table. All the data in the column will be lost.
  - You are about to drop the `RegionCity` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `regionId` to the `DoctorProfile` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "DoctorProfile" DROP CONSTRAINT "DoctorProfile_regionCityId_fkey";

-- AlterTable
ALTER TABLE "DoctorProfile" DROP COLUMN "regionCityId",
ADD COLUMN     "regionId" TEXT NOT NULL;

-- DropTable
DROP TABLE "RegionCity";

-- CreateTable
CREATE TABLE "Region" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "mapUrl" TEXT,
    "regionImgUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Region_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Region_name_key" ON "Region"("name");

-- AddForeignKey
ALTER TABLE "DoctorProfile" ADD CONSTRAINT "DoctorProfile_regionId_fkey" FOREIGN KEY ("regionId") REFERENCES "Region"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
