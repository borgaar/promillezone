import { Input } from "@/components/ui/input";
import { createTRPCRouter, protectedProcedure } from "@/server/api/trpc";
import { z } from "zod";

export const collectiveRoute = createTRPCRouter({
  createCollective: protectedProcedure
    .input(
      z.object({
        collectiveName: z.string().min(1).max(32),
        streetName: z.string().min(1),
        houseNumber: z.string().min(1),
        postalCode: z.string().min(1),
      }),
    )
    .mutation(
      async ({
        ctx,
        input: { collectiveName, streetName, postalCode, houseNumber },
      }) => {
        await ctx.db.$transaction(async (_) => {
          const collective = await ctx.db.collective.create({
            data: {
              name: collectiveName,
              postalCode: postalCode,
              houseNumber: houseNumber,
              streetName: streetName,
            },
          });
          await ctx.db.user.update({
            data: {
              collectiveId: collective.id,
            },
            where: { id: ctx.session.user.id },
          });
        });
      },
    ),
});
