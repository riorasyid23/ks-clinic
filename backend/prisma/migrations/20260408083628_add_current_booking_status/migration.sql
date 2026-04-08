-- AlterTable
ALTER TABLE "Encounter" ADD COLUMN     "currentStatus" "BookingStatus" NOT NULL DEFAULT 'PENDING';
