import { collectiveProcedure, createTRPCRouter } from "@/server/api/trpc";
import { z } from "zod";

export const choreRouter = createTRPCRouter({
  getChores: collectiveProcedure.query(async ({ ctx }) => {
    return await ctx.db.chore.findMany({
      where: {
        collectiveId: ctx.session.user.collectiveId,
      },
    });
  }),
  getDueChores: collectiveProcedure
    .input(
      z.object({
        collectiveId: z.string(),
        from: z.date(),
        to: z.date(),
      }),
    )
    .query(async ({ ctx, input: { collectiveId, from, to } }) => {
      if (to < from) {
        throw new Error(
          "Invalid date range: " +
            from.toISOString() +
            " -> " +
            to.toISOString() +
            ". 'to' date must be after 'from' date.",
        );
      }

      return await ctx.db.dueChore.findMany({
        where: {
          chore: {
            collectiveId: collectiveId,
          },
          AND: {
            dueDate: {
              gte: from,
              lte: to,
            },
          },
        },
        include: {
          chore: true,
          assignee: true,
        },
      });
    }),
  completeChore: collectiveProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: dueChoreId }) => {
      await ctx.db.dueChore.update({
        data: {
          completedAt: new Date(),
        },
        where: {
          id: dueChoreId,
        },
      });
    }),
  createChore: collectiveProcedure
    .input(
      z.object({
        name: z.string().nonempty(),
        frequency: z.number().nonnegative().min(1),
      }),
    )
    .mutation(async ({ ctx, input: { name, frequency } }) => {
      await ctx.db.chore.create({
        data: {
          name: name,
          frequency: frequency,
          collectiveId: ctx.session.user.collectiveId,
        },
      });
    }),
  modifyChore: collectiveProcedure
    .input(
      z.object({
        id: z.string(),
        name: z.string().optional(),
        frequency: z.number().nonnegative().min(1).optional(),
      }),
    )
    .mutation(async ({ ctx, input: { id, name, frequency } }) => {
      const updateData: { name?: string; frequency?: number } = {};

      if (name !== undefined) updateData.name = name;
      if (frequency !== undefined) updateData.frequency = frequency;

      await ctx.db.chore.update({
        data: updateData,
        where: {
          id: id,
        },
      });
    }),
  removeChore: collectiveProcedure
    .input(z.string())
    .mutation(async ({ ctx, input: choreId }) => {
      await ctx.db.chore.delete({
        where: {
          id: choreId,
        },
      });
    }),
  generateDueChores: collectiveProcedure
    .input(
      z.object({
        id: z.string(),
        numberOfWeeks: z.number().nonnegative().min(1).max(26),
      }),
    )
    .mutation(
      async ({ ctx, input: { id, numberOfWeeks: numberOfWeeksToGen } }) => {
        return await ctx.db.$transaction(async (db) => {
          const chore = await db.chore.findUnique({ where: { id } });

          if (chore === null) {
            throw new Error("Chore not found");
          }

          const frequency = chore.frequency;
          const daysToGenerate = numberOfWeeksToGen * 7;
          const assignees = await db.user.findMany({
            where: {
              collectiveId: ctx.session.user.collectiveId,
            },
          });

          if (assignees.length === 0) {
            throw new Error("No users in collective");
          }

          // Shuffle assignees
          assignees.sort((_, __) => Math.random() - 0.5);

          // Remove all existing due chores for this chore
          await db.dueChore.deleteMany({
            where: {
              choreId: id,
              dueDate: {
                gte: new Date(),
              },
            },
          });

          const dueChoresToCreate = [];

          // Regenerate due chores
          for (let day = 0; day < daysToGenerate; day++) {
            if (day % frequency === 0) {
              const assignee = assignees[day % assignees.length]!.id;
              dueChoresToCreate.push({
                choreId: id,
                dueDate: new Date(Date.now() + day * 24 * 60 * 60 * 1000),
                assigneeId: assignee,
              });
            }
          }

          await db.dueChore.createMany({
            data: dueChoresToCreate,
          });

          return db.dueChore.findMany({
            where: {
              choreId: id,
              dueDate: {
                gte: new Date(),
              },
            },
          });
        });
      },
    ),
});
