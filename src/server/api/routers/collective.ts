import {
  collectiveProcedure,
  createTRPCRouter,
  protectedProcedure,
} from "@/server/api/trpc";
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
        await ctx.db.$transaction(async (tx) => {
          const collective = await tx.collective.create({
            data: {
              name: collectiveName,
              postalCode: postalCode,
              houseNumber: houseNumber,
              streetName: streetName,
            },
          });
          await tx.user.update({
            data: {
              collectiveId: collective.id,
            },
            where: { id: ctx.session.user.id },
          });
        });
      },
    ),
  createJoinToken: collectiveProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: collectiveId }) => {
      let joinToken = await ctx.db.joinCollectiveToken.create({
        data: {
          collectiveId: collectiveId,
          createdBy: ctx.session.user.id,
        },
      });

      // Do cleanup: delete all expired tokens
      const cleanupExpiredTokens = async () => {
        try {
          await ctx.db.joinCollectiveToken.deleteMany({
            where: {
              expiresAt: {
                lt: new Date(),
              },
            },
          });
        } catch (e) {
          console.error(e);
        }
      };
      cleanupExpiredTokens();

      return joinToken.token;
    }),
  joinCollective: protectedProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: token }) => {
      ctx.db.$transaction(async (tx) => {
        const result = await tx.joinCollectiveToken.findUnique({
          select: { collectiveId: true },
          where: {
            token: token,
            AND: {
              expiresAt: {
                gt: new Date(),
              },
            },
          },
        });

        if (!result) {
          throw new Error("Invalid token");
        }

        await tx.user.update({
          data: {
            collectiveId: result.collectiveId,
          },
          where: {
            id: ctx.session.user.id,
          },
        });
      });
    }),
});
