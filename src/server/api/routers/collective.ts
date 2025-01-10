import { Input } from "@/components/ui/input";
import {
  createTRPCRouter,
  protectedProcedure,
  publicProcedure,
} from "@/server/api/trpc";
import { z } from "zod";

export const collectiveRoute = createTRPCRouter({
  createCollective: protectedProcedure
    .input(
      z.object({
        collectiveName: z.string().min(1).max(32),
        address: z.string().min(1),
      }),
    )
    .mutation(async ({ ctx, input: { collectiveName, address } }) => {
      await ctx.db.$transaction(async (tx) => {
        const collective = await ctx.db.collective.create({
          data: {
            name: collectiveName,
            address: address,
          },
        });
        await ctx.db.user.update({
          data: {
            collectiveId: collective.id,
          },
          where: { id: ctx.session.user.id },
        });
      });
    }),
});
