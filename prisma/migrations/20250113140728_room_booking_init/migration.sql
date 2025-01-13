-- CreateTable
CREATE TABLE "RoomBooking" (
    "date" TIMESTAMP(3) NOT NULL,
    "bookerId" TEXT NOT NULL,

    CONSTRAINT "RoomBooking_pkey" PRIMARY KEY ("date","bookerId")
);

-- AddForeignKey
ALTER TABLE "RoomBooking" ADD CONSTRAINT "RoomBooking_bookerId_fkey" FOREIGN KEY ("bookerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
