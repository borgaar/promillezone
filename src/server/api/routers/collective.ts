import {
  collectiveProcedure,
  createTRPCRouter,
  protectedProcedure,
} from "@/server/api/trpc";
import { PrismaClient } from "@prisma/client";
import { z } from "zod";

const collectiveIdFromJoinToken = async (
  db: Omit<
    PrismaClient,
    "$transaction" | "$on" | "$connect" | "$disconnect" | "$use" | "$extends"
  >,
  token: string,
) => {
  return await db.joinCollectiveToken.findUnique({
    where: {
      token: token,
      AND: {
        expiresAt: {
          gt: new Date(Date.now()),
        },
      },
    },
    select: {
      collectiveId: true,
    },
  });
};

export const collectiveRouter = createTRPCRouter({
  getCollective: collectiveProcedure.query(async ({ ctx }) => {
    return await ctx.db.collective.findUnique({
      where: {
        id: ctx.session.user.collectiveId,
      },
      include: {
        users: true,
      },
    });
  }),
  getCollectivePreview: protectedProcedure
    .input(z.string())
    .query(async ({ ctx, input: inviteToken }) => {
      const result = await collectiveIdFromJoinToken(ctx.db, inviteToken);

      if (!result) throw Error("Invalid token");

      return await ctx.db.collective.findUnique({
        where: {
          id: result.collectiveId,
        },
        select: {
          users: {
            select: {
              name: true,
              image: true,
            },
          },
        },
      });
    }),
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
        const result = await collectiveIdFromJoinToken(tx, token);

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
