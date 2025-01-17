import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { TRPCError } from "@trpc/server";
import { z } from "zod";

export const roomRouter = createTRPCRouter({
  createRoomBooking: collectiveProcedure
    .input(z.date())
    .mutation(async ({ ctx, input: date }) => {
      await ctx.db.$transaction(async (db) => {
        if (
          await db.roomBooking.findUnique({
            where: {
              date_collectiveId: {
                date: date,
                collectiveId: ctx.session.user.collectiveId,
              },
            },
          })
        ) {
          throw new TRPCError({
            code: "BAD_REQUEST",
            message: "Room is already booked for this date",
          });
        }

        await db.roomBooking.create({
          data: {
            date,
            collectiveId: ctx.session.user.collectiveId,
            bookerId: ctx.session.user.id,
          },
        });
      });
    }),
  removeRoomBooking: collectiveProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: bookingId }) => {
      await ctx.db.roomBooking.delete({
        where: {
          id: bookingId,
        },
      });
    }),
  getRoomBookings: collectiveProcedure.query(async ({ ctx }) => {
    return await ctx.db.roomBooking.findMany({
      where: {
        collectiveId: ctx.session.user.collectiveId,
      },
      include: {
        booker: true,
      },
    });
  }),
});
