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
    const { trashAddressId, trashProviderSlug } =
      await ctx.db.collective.findUniqueOrThrow({
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

    return provider.getTrashSchedule(trashAddressId);
  }),

  setupProvider: protectedProcedure
    .input(
      z.object({
        providerSlug: z.string(),
        address: z.string(),
      }),
    )
    .mutation(async ({ ctx, input }) => {
      const provider = TrashProviderFactory.get(input.providerSlug);

      if (!provider) {
        const providers = Object.keys(TrashProviderFactory.getAll()).join(", ");

        throw new TRPCError({
          code: "INTERNAL_SERVER_ERROR",
          message: `Provider not found:${input.providerSlug}. Should be one of ${providers}`,
        });
      }

      const addressId = await provider.getAddressId(input.address);

      // TODO save addressId and provider slug to database
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
