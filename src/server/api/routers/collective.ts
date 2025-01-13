import {
  collectiveProcedure,
  createTRPCRouter,
  protectedProcedure,
} from "@/server/api/trpc";
import type { PrismaClient } from "@prisma/client";
import { z } from "zod";
import { env } from "../../../env";

const collectiveIdFromJoinToken = async (
  db: Pick<PrismaClient, "joinCollectiveToken">,
  token: string,
): Promise<{ collectiveId: string } | null> => {
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

const cleanupExpiredTokens = async (
  db: Pick<PrismaClient, "joinCollectiveToken">,
) => {
  try {
    await db.joinCollectiveToken.deleteMany({
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

export const collectiveRouter = createTRPCRouter({
  getCollective: collectiveProcedure.query(async ({ ctx }) => {
    return await ctx.db.collective.findUniqueOrThrow({
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
          name: true,
          users: {
            select: {
              name: true,
              image: true,
            },
          },
        },
      });
    }),
  removeMember: collectiveProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: memberToRemove }) => {
      await ctx.db.user.update({
        data: {
          collectiveId: null,
        },
        where: {
          id: memberToRemove,
          AND: {
            collective: {
              users: {
                some: {
                  id: ctx.session.user.id,
                },
              },
            },
          },
        },
      });
    }),
  createCollective: protectedProcedure
    .input(
      z.object({
        collectiveName: z.string().nonempty().max(32),
        streetName: z.string().nonempty(),
        houseNumber: z.string().nonempty(),
        postalCode: z.string().nonempty(),
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
  createJoinToken: collectiveProcedure.mutation(async ({ ctx }) => {
    const joinToken = await ctx.db.joinCollectiveToken.create({
      data: {
        collectiveId: ctx.session.user.collectiveId,
        createdBy: ctx.session.user.id,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      },
    });

    void cleanupExpiredTokens(ctx.db);

    return {
      token: joinToken,
      url: `${env.NEXTAUTH_URL}/invite?code=${joinToken.token}`,
    };
  }),
  joinCollective: protectedProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: token }) => {
      await ctx.db.$transaction(async (tx) => {
        const result = await collectiveIdFromJoinToken(tx, token);

        void cleanupExpiredTokens(ctx.db);

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
