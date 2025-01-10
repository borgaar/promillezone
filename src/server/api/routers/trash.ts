import { z } from "zod";

import {
  createTRPCRouter,
  protectedProcedure,
  publicProcedure,
} from "@/server/api/trpc";
import { TRPCError } from "@trpc/server";
import { TrashProviderFactory } from "../../trash/factory";

export const trashRouter = createTRPCRouter({
  getProviders: publicProcedure.query(() => TrashProviderFactory.getAll()),

  getSchedule: protectedProcedure.query(async ({ ctx }) => {
    const {
      trashAddressId,
      trashProviderSlug,
      houseNumber,
      postalCode,
      streetName,
    } = await ctx.db.collective.findUniqueOrThrow({
      where: {
        id: ctx.session.user.collectiveId,
      },
    });

    if (!trashAddressId || !trashProviderSlug) {
      throw new TRPCError({
        code: "PRECONDITION_FAILED",
        message: "Trash provider is not set up!",
      });
    }

    const provider = TrashProviderFactory.get(trashProviderSlug);

    if (!provider) {
      throw new TRPCError({
        code: "INTERNAL_SERVER_ERROR",
        message: "Provider not found:" + trashProviderSlug,
      });
    }

    const schedule = await provider.getTrashSchedule(trashAddressId, {
      houseNumber,
      postalCode,
      streetName,
    });

    schedule.sort(
      (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime(),
    );

    return schedule;
  }),

  setupProvider: protectedProcedure
    .input(z.object({ providerSlug: z.string() }))
    .mutation(async ({ ctx, input }) => {
      const provider = TrashProviderFactory.get(input.providerSlug);

      if (!provider) {
        const providers = Object.keys(TrashProviderFactory.getAll()).join(", ");

        throw new TRPCError({
          code: "INTERNAL_SERVER_ERROR",
          message: `Provider not found:${input.providerSlug}. Should be one of ${providers}`,
        });
      }

      const address = await ctx.db.collective.findUniqueOrThrow({
        where: {
          id: ctx.session.user.collectiveId,
        },
        select: {
          postalCode: true,
          houseNumber: true,
          streetName: true,
        },
      });

      const addressId = await provider.getAddressId(address);

      await ctx.db.collective.update({
        where: {
          id: ctx.session.user.collectiveId,
        },
        data: {
          trashProviderSlug: input.providerSlug,
          trashAddressId: addressId,
        },
      });
    }),
});
